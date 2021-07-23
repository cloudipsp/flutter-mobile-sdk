#import "CloudipspMobilePlugin.h"

#import <PassKit/PassKit.h>

API_AVAILABLE(ios(11.0))
@interface CloudipspMobilePlugin () <PKPaymentAuthorizationViewControllerDelegate>

@property (nonatomic, strong) FlutterResult applePayResult;
@property (nonatomic, strong) FlutterResult applePayCompleteResult;
@property (nonatomic, strong) void (^applePayCallback)(PKPaymentAuthorizationResult *);

@end


@implementation CloudipspMobilePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"cloudipsp_mobile"
            binaryMessenger:[registrar messenger]];
  CloudipspMobilePlugin* instance = [[CloudipspMobilePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"supportsApplePay" isEqualToString:call.method]) {
    result(@([PKPaymentAuthorizationViewController canMakePayments]));
  } else if ([@"applePay" isEqualToString:call.method]) {
      [self applePay:call.arguments result:result];
  } else if ([@"applePayComplete" isEqualToString:call.method]) {
      [self applePayComplete:[call.arguments objectForKey:@"success"] result:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)applePay:(NSDictionary *)params result:(FlutterResult)result {
    self.applePayResult = result;
    
    NSDictionary *config = [params objectForKey:@"config"];
    NSInteger amount = [[params objectForKey:@"amount"] intValue];
    NSString *currency = [params objectForKey:@"currency"];
    NSString *about = [params objectForKey:@"about"];
    
    NSDictionary* data = [config objectForKey:@"data"];
    PKPaymentRequest *paymentRequest = [[PKPaymentRequest alloc] init];
    paymentRequest.countryCode = @"US";
    paymentRequest.supportedNetworks = @[PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex];
    paymentRequest.merchantCapabilities = PKMerchantCapability3DS;
    paymentRequest.merchantIdentifier = [data objectForKey:@"merchantIdentifier"];
    paymentRequest.currencyCode = currency;
    
    NSDecimalNumber *fixedAmount = [[NSDecimalNumber alloc] initWithMantissa:amount exponent:-2 isNegative:NO];
    NSMutableArray *items = [NSMutableArray new];
    PKPaymentSummaryItem *infoItem = [PKPaymentSummaryItem summaryItemWithLabel:about amount:fixedAmount];
    [items addObject:infoItem];

    PKPaymentSummaryItem *mainItem = [PKPaymentSummaryItem summaryItemWithLabel: [config objectForKey:@"businessName"] amount:fixedAmount];
    [items addObject:mainItem];
    paymentRequest.paymentSummaryItems = items;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        PKPaymentAuthorizationViewController *controller = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:paymentRequest];
        controller.delegate = self;
        UIViewController *topViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        [topViewController presentViewController:controller animated:YES completion:nil];
    });
}

- (UIViewController *)topViewController{
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

- (void)applePayComplete:(BOOL)success result:(FlutterResult)result {
    self.applePayCompleteResult = result;
    if (self.applePayCallback) {
        if (@available(iOS 11.0, *)) {
            void (^callback)(PKPaymentAuthorizationResult *) = self.applePayCallback;
            self.applePayCallback = nil;
        
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    callback([[PKPaymentAuthorizationResult alloc] initWithStatus:PKPaymentAuthorizationStatusSuccess errors:nil]);
                } else {
                    callback([[PKPaymentAuthorizationResult alloc] initWithStatus:PKPaymentAuthorizationStatusFailure errors:nil]);
                }
            });
        }
    }
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    FlutterResult completeResult = self.applePayCompleteResult;
    self.applePayCompleteResult = nil;

    if (completeResult == nil) {
        FlutterResult result = self.applePayResult;
        self.applePayResult = nil;
        
        [controller dismissViewControllerAnimated:YES completion:^{
            result([FlutterError errorWithCode:@"UserCanceled" message:@"User canceled ApplePay authentication" details:nil]);
        }];
    } else {
        [controller dismissViewControllerAnimated:YES completion:^{
            completeResult(nil);
        }];
    }
}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                   handler:(void (^)(PKPaymentAuthorizationResult *result))completion
API_AVAILABLE(ios(11.0))
{
    self.applePayCallback = completion;
    NSError *jsonError;
    
    NSDictionary *paymentData = [NSJSONSerialization JSONObjectWithData:payment.token.paymentData options:NSJSONReadingMutableContainers error:&jsonError];
    NSDictionary *paymentMethod = @{
                                    @"displayName":payment.token.paymentMethod.displayName,
                                    @"network":payment.token.paymentMethod.network,
                                    @"type": [CloudipspMobilePlugin paymentMethodName: payment.token.paymentMethod.type],
                                    };
    NSDictionary *paymentToken = @{
                                   @"paymentData": paymentData,
                                   @"paymentMethod": paymentMethod,
                                   @"transactionIdentifier": payment.token.transactionIdentifier
                                   };
    NSMutableDictionary *data = [NSMutableDictionary new];
    [data setObject:paymentToken forKey:@"token"];
    if (payment.shippingContact != nil) {
        NSDictionary *shipingContact = @{
                                         @"emailAddress": payment.shippingContact.emailAddress,
                                         @"familyName": payment.shippingContact.name.familyName,
                                         @"givenName": payment.shippingContact.name.givenName,
                                         @"phoneNumber": payment.shippingContact.phoneNumber.stringValue,
                                         };
        [data setObject:shipingContact forKey:@"shippingContact"];
    }
    self.applePayResult(data);
    self.applePayResult = nil;
}

+ (NSString *)paymentMethodName:(PKPaymentMethodType)type API_AVAILABLE(ios(9.0)){
    switch (type) {
        case PKPaymentMethodTypeDebit:
            return @"debit";
        case PKPaymentMethodTypeCredit:
            return @"credit";
        case PKPaymentMethodTypePrepaid:
            return @"prepaid";
        case PKPaymentMethodTypeStore:
            return @"store";
        default:
            return @"unknown";
    }
}

@end
