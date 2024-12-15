//
//  ViewController.m
//  Brokenithm-iOS
//
//  Created by ester on 2020/2/28.
//  Copyright © 2020 esterTion. All rights reserved.
//

#import "ViewController.h"
#import "FunctionButton.h"

@interface ViewController () {
    BOOL pendingHideStatus;
}

@end

#define FUNCTION_MENU_HEIGHT 60.0f * 7

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    pendingHideStatus = NO;
    [NSUserDefaults.standardUserDefaults registerDefaults:@{
        @"enableAir": @YES,
        @"autoPopMenu": @YES,
        @"invertAir": @NO,
        @"menuDuration": @1.0,
        @"fullSliderSensors": @YES,
        @"widthAdjuster": @1.0
    }];
    
    funcViewOn = YES;
    openCloseEventOnce = NO;
    
    // network permission
    /*
    {
        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://captive.apple.com/"]];
        [NSURLConnection sendAsynchronousRequest:req
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *resp, NSData *data, NSError *error) {}];
    }
     */
    
    // io view
    const struct screenInfo info = [self setScreenInfo];
    
    float sliderHeight = screenHeight;
    self.airIOView = [[UIView alloc] initWithFrame:CGRectMake(info.offsetX, 0, screenWidth, screenHeight*0.4)];
    self.sliderIOView = [[UIView alloc] initWithFrame:CGRectMake(info.offsetX, 0, screenWidth, sliderHeight)];
    self.airIOView.backgroundColor = [UIColor blackColor];
    self.airIOView.layer.borderWidth = 1.0f;
    self.airIOView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.sliderIOView.layer.borderWidth = 1.0f;
    self.sliderIOView.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.view addSubview:self.sliderIOView];
    [self.view addSubview:self.airIOView];
    
    // connect status view
    connectStatusView = [[UILabel alloc] initWithFrame:CGRectMake(info.width - 200.0, screenHeight * 0.1, 200.0, 50.0)];
    connectStatusView.userInteractionEnabled = false;
    connectStatusView.text = [[NSBundle mainBundle] localizedStringForKey:@"Not connected" value:@"" table:nil]
    ;
    connectStatusView.textAlignment = NSTextAlignmentCenter;
    connectStatusView.textColor = [UIColor whiteColor];
    connectStatusView.numberOfLines = 1;
    connectStatusView.backgroundColor = [UIColor blackColor];
    connectStatusView.layer.borderColor = [UIColor whiteColor].CGColor;
    connectStatusView.layer.borderWidth = 1.0;
    [self.view addSubview:connectStatusView];
    
    // function button view
    {
        functionBtnView = [[UIView alloc] initWithFrame:CGRectMake(0, screenHeight*0.1, 250, FUNCTION_MENU_HEIGHT)];
        [self.view addSubview:functionBtnView];
        // open/close btn
        UIView *openCloseBtnBorder;
        openCloseBtnBorder = [[UIView alloc] initWithFrame:CGRectMake(195, 0, 55, 50)];
        openCloseBtnBorder.backgroundColor = [UIColor blackColor];
        openCloseBtnBorder.layer.borderColor = [UIColor whiteColor].CGColor;
        openCloseBtnBorder.layer.borderWidth = 1.0;
        openCloseBtnBorder.layer.cornerRadius = 5;
        [functionBtnView addSubview:openCloseBtnBorder];
        openCloseBtn = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 50, 50)];
        openCloseBtn.textColor = [UIColor whiteColor];
        openCloseBtn.textAlignment = NSTextAlignmentCenter;
        openCloseBtn.text = @"◀";
        openCloseBtn.font = [UIFont systemFontOfSize:30];
        UITapGestureRecognizer *openCloseTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeFunc)];
        openCloseHold = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(openOrCloseFunc)];
        openCloseHold.minimumPressDuration = 1;
        [openCloseBtnBorder addGestureRecognizer:openCloseTap];
        [openCloseBtnBorder addGestureRecognizer:openCloseHold];
        [openCloseBtnBorder addSubview:openCloseBtn];
        // functions
        {
            NSArray<NSArray<NSString*>*> *functions = @[
                @[@"test", @"TEST"],
                @[@"service", @"SERVICE"],
                @[@"coin", [[NSBundle mainBundle] localizedStringForKey:@"Insert Coin" value:@"" table:nil]],
                @[@"card", [[NSBundle mainBundle] localizedStringForKey:@"Read Card" value:@"" table:nil]]
            ];
            float offset = 0;
            for (NSArray<NSString*> *item in functions) {
                FunctionButton *btn = [[FunctionButton alloc] initAtY:offset];
                btn.name = item[0];
                btn.text = item[1];
                [functionBtnView addSubview:btn];
                offset += 60;
            }
            UIView *enableAir;
            UILabel *enableAirLabel;
            enableAir = [[UIView alloc] initWithFrame:CGRectMake(0, offset, 200, 60)];
            enableAir.backgroundColor = [UIColor blackColor];
            enableAir.layer.borderColor = [UIColor whiteColor].CGColor;
            enableAir.layer.borderWidth = 1.0;
            [functionBtnView addSubview:enableAir];
            enableAirLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 130, 60)];
            enableAirLabel.textAlignment = NSTextAlignmentRight;
            enableAirLabel.textColor = [UIColor whiteColor];
            enableAirLabel.numberOfLines = 1;
            enableAirLabel.text = [[NSBundle mainBundle] localizedStringForKey:@"Enable Air Input" value:@"" table:nil];
            [enableAir addSubview:enableAirLabel];
            enableAirToggle = [[UISwitch alloc] initWithFrame:CGRectMake(135, 13, 50, 27)];
            [enableAir addSubview:enableAirToggle];
            offset += 60;
            
            UIView *enableFullSlideSensors;
            UILabel *enableFullSlideSensorsLabel;
            enableFullSlideSensors = [[UIView alloc] initWithFrame:CGRectMake(0, offset, 200, 60)];
            enableFullSlideSensors.backgroundColor = [UIColor blackColor];
            enableFullSlideSensors.layer.borderColor = [UIColor whiteColor].CGColor;
            enableFullSlideSensors.layer.borderWidth = 1.0;
            [functionBtnView addSubview:enableFullSlideSensors];
            enableFullSlideSensorsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 130, 60)];
            enableFullSlideSensorsLabel.textAlignment = NSTextAlignmentRight;
            enableFullSlideSensorsLabel.textColor = [UIColor whiteColor];
            enableFullSlideSensorsLabel.numberOfLines = 1;
            enableFullSlideSensorsLabel.text = [[NSBundle mainBundle] localizedStringForKey:@"32 Slide Sensors" value:@"" table:nil];
            [enableFullSlideSensors addSubview:enableFullSlideSensorsLabel];
            enableFullSlideSensorToggle = [[UISwitch alloc] initWithFrame:CGRectMake(142, 13, 50, 27)];
            [enableFullSlideSensors addSubview:enableFullSlideSensorToggle];
            offset += 60;
            
            FunctionButton *moreBtn = [[FunctionButton alloc] initAtY:offset];
            offset += 60;
            moreBtn.name = @"more_setting_button";
            moreBtn.text = [[NSBundle mainBundle] localizedStringForKey:@"More..." value:@"" table:nil];
            moreBtn.userInteractionEnabled = YES;
            UITapGestureRecognizer *moreBtnTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpToSetting)];
            [moreBtn addGestureRecognizer:moreBtnTap];
            [functionBtnView addSubview:moreBtn];
            
            [self loadPrefs];
            [enableAirToggle addTarget:self action:@selector(enableAirChanged) forControlEvents:UIControlEventValueChanged];
            [enableFullSlideSensorToggle addTarget:self action:@selector(updateFullSlideSensorState) forControlEvents:UIControlEventValueChanged];
        }
    }
    
    // led gradient layer
    ledBackground = [CAGradientLayer layer];
    ledBackground.frame = CGRectMake(0, 0, screenWidth, sliderHeight);
    [self.sliderIOView.layer addSublayer:ledBackground];
    ledBackground.startPoint = CGPointMake(1,0);
    ledBackground.endPoint = CGPointMake(0,0);
    ledBackground.actions = [NSDictionary dictionaryWithObject:[NSNull null] forKey:@"colors"];
    {
        float pointOffset = 0;
        float gapSmall = 1.0/16/8, gapBig = 1.0/16*6/8;
        NSMutableArray *locations = [NSMutableArray arrayWithCapacity:49];
        for (int i=0,off=-1; i<16; i++) {
            locations[++off] = [NSNumber numberWithFloat:pointOffset];
            pointOffset += gapSmall;
            locations[++off] = [NSNumber numberWithFloat:pointOffset];
            pointOffset += gapBig;
            locations[++off] = [NSNumber numberWithFloat:pointOffset];
            pointOffset += gapSmall;
        }
        locations[48] = @1;
        ledBackground.locations = locations;
    }
    
    struct CGColor *gridBorderColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
    float airOffset=0, airHeight = screenHeight*0.4/6;
    for (int i=0;i<6;i++) {
        UIView *airInput = [[UIView alloc] initWithFrame:CGRectMake(0, airOffset, screenWidth, airHeight)];
        airInput.layer.borderWidth = 1.0f;
        airInput.layer.borderColor = gridBorderColor;
        airOffset += airHeight;
        [self.airIOView addSubview:airInput];
    }
    
    float sliderWidth = screenWidth / 16, sliderOffset = 0;
    for (int i=0;i<16;i++) {
        UIView *sliderInput = [[UIView alloc] initWithFrame:CGRectMake(sliderOffset, 0, sliderWidth, sliderHeight)];
        sliderInput.layer.borderWidth = 1.0f;
        sliderInput.layer.borderColor = gridBorderColor;
        sliderOffset += sliderWidth;
        [self.sliderIOView addSubview:sliderInput];
    }
    
    server = [[SocketDelegate alloc] init];
    server.parentVc = self;
    NSLog(@"server created");
}

-(void)loadPrefs {
    // enable air
    BOOL pref = [NSUserDefaults.standardUserDefaults boolForKey:@"enableAir"];
    [enableAirToggle setOn:pref animated:NO];
    [self updateAirEnabled:pref];
    
    // auto pop
    autoPopMenu = [NSUserDefaults.standardUserDefaults boolForKey:@"autoPopMenu"];
    
    // invert air
    pref = [NSUserDefaults.standardUserDefaults boolForKey:@"invertAir"];
    [self updateAirInverted:pref];
    
    // hold duration
    menuHoldDuration = [NSUserDefaults.standardUserDefaults valueForKey:@"menuDuration"];
    openCloseHold.minimumPressDuration = [menuHoldDuration floatValue];
    
    // 32 or 16 slider sensors
    bool ss = [NSUserDefaults.standardUserDefaults boolForKey:@"fullSliderSensors"];
    [enableFullSlideSensorToggle setOn:ss animated:NO];
}
-(void)updateFullSlideSensorState {
    bool value = enableFullSlideSensorToggle.on;
    [NSUserDefaults.standardUserDefaults setBool:value forKey:@"fullSliderSensors"];
}
-(void)updateLed:(NSData*)rgbData {
    if (rgbData.length != 32*3) return;
    NSMutableArray *colorArr = [NSMutableArray arrayWithCapacity:33];
    colorArr[0] = (__bridge id)([UIColor colorWithWhite:0 alpha:0].CGColor);
    uint8_t *rgb = (uint8_t*)rgbData.bytes;
    for (int i=0, off=0; i<32; i++) {
        float r = rgb[i*3+1], g = rgb[i*3+2], b = rgb[i*3];
        r /= 255.0;
        g /= 255.0;
        b /= 255.0;
        UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1];
        colorArr[++off] = (__bridge id)color.CGColor;
        off += (i+1)&1;
        colorArr[off] = (__bridge id)color.CGColor;
    }
    ledBackground.colors = colorArr;
    [ledBackground setNeedsDisplay];
}
-(void)enableAirChanged{
    BOOL pref = enableAirToggle.on;
    [NSUserDefaults.standardUserDefaults setBool:pref forKey:@"enableAir"];
    [self updateAirEnabled:pref];
    
    uint8_t airConf[] = {4, 'A', 'I', 'R', pref};
    NSData *airConfData = [NSData dataWithBytes:airConf length:sizeof(airConf)];
    [server BroadcastData:airConfData];
}
-(void)updateAirEnabled:(BOOL)enable {
    self.airIOView.hidden = !enable;
    airEnabled = enable;
}

-(void)updateAirInverted:(BOOL)invert {
    if (invertAir != invert) {
        const struct screenInfo info = [self setScreenInfo];
        self.airIOView.frame = CGRectMake(info.offsetX, invert ? screenHeight * 0.6 : 0, screenWidth, screenHeight * 0.4);
        invertAir = invert;
    }
}

-(void)openOrCloseFunc {
    if (self->touchCount > 1) return;
    if (funcViewOn) {
        [self closeFunc];
    } else {
        [self openFunc];
    }
}
-(void)closeFunc {
    if (!openCloseEventOnce && funcViewOn) {
        funcViewOn = NO;
        openCloseEventOnce = YES;
        [UIView animateWithDuration:0.3 animations:^{
            self->functionBtnView.frame = CGRectMake(-200, self->screenHeight*0.1, 250, FUNCTION_MENU_HEIGHT);
        }];
        openCloseBtn.text = @"▶";
        struct ioBuf buf = {0};
        [self sendIoBuf:&buf];
    }
}
-(void)openFunc {
    if (!openCloseEventOnce && !funcViewOn) {
        funcViewOn = YES;
        openCloseEventOnce = YES;
        [UIView animateWithDuration:0.3 animations:^{
            self->functionBtnView.frame = CGRectMake(0, self->screenHeight*0.1, 250, FUNCTION_MENU_HEIGHT);
        }];
        openCloseBtn.text = @"◀";
        struct ioBuf buf = {0};
        [self sendIoBuf:&buf];
    }
}
-(void)jumpToSetting {
    [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

-(BOOL)prefersStatusBarHidden { return kCFCoreFoundationVersionNumber < 1443.00; }
-(UIRectEdge)preferredScreenEdgesDeferringSystemGestures { return UIRectEdgeAll; }
-(BOOL)prefersHomeIndicatorAutoHidden { return YES; }
-(UIStatusBarStyle) preferredStatusBarStyle { return UIStatusBarStyleLightContent; }
-(UIEditingInteractionConfiguration)editingInteractionConfiguration { return UIEditingInteractionConfigurationNone; }

-(struct screenInfo) setScreenInfo {
    CGRect screenSize = [UIScreen mainScreen].bounds;
    NSNumber *widthAdjust = [NSUserDefaults.standardUserDefaults valueForKey:@"widthAdjuster"];
    
    struct screenInfo info = {};
    info.width = screenSize.size.width;
    info.widthMagnification = widthAdjust.floatValue;
    info.adjustedWidth = info.width * info.widthMagnification;
    info.height = screenSize.size.height;
    info.size = screenSize;
    info.offsetX = (info.width - info.adjustedWidth) / 2;
    
    screenWidth = info.adjustedWidth;
    screenHeight = info.height;
    
    return info;
}
-(void)sendIoBuf:(struct ioBuf*)buf {
    buf->len = sizeof(*buf) - 1;
    buf->head[0] = 'I';
    buf->head[1] = 'N';
    buf->head[2] = 'P';
    NSData* io = [NSData dataWithBytes:buf length:sizeof(*buf)];
    [server BroadcastData:io];
}
-(void)updateTouches:(UIEvent *)event {
    self->touchCount = event.allTouches.count;
    if (openCloseEventOnce) {
        if (event.allTouches.count == 1 && [event.allTouches anyObject].phase == UITouchPhaseEnded) {
            openCloseEventOnce = NO;
        }
        return;
    }
    float airHeight = screenHeight * 0.4;
    float airIOHeight = airHeight / 6;
    float sliderIOWidth = screenWidth / 16;
    float sliderIOHeight = screenHeight - (airEnabled ? airHeight : 0);
    struct ioBuf buf = {0};
    for (UITouch *touch in event.allTouches) {
        UITouchPhase phase = touch.phase;
        if (phase == UITouchPhaseBegan || phase == UITouchPhaseMoved || phase == UITouchPhaseStationary) {
            if (funcViewOn) {
                CGPoint funcPoint = [touch locationInView:functionBtnView];
                if (funcPoint.x > 0 && funcPoint.x < 200 &&
                    funcPoint.y > 0 && funcPoint.y < FUNCTION_MENU_HEIGHT) {
                    if (funcPoint.y < 60) {
                        buf.testBtn = 1;
                    } else if (funcPoint.y < 120) {
                        buf.serviceBtn = 1;
                    } else if (funcPoint.y < 180) {
                        if (phase == UITouchPhaseBegan) {
                            uint8_t btnPress[] = {4, 'F', 'N', 'C', BNI_FUNCTION_COIN};
                            NSData *btnPressData = [NSData dataWithBytes:btnPress length:sizeof(btnPress)];
                            [server BroadcastData:btnPressData];
                        }
                    } else if (funcPoint.y < 240) {
                        if (phase == UITouchPhaseBegan) {
                            uint8_t btnPress[] = {4, 'F', 'N', 'C', BNI_FUNCTION_CARD};
                            NSData *btnPressData = [NSData dataWithBytes:btnPress length:sizeof(btnPress)];
                            [server BroadcastData:btnPressData];
                        }
                    }
                    continue;
                }
            }
            CGPoint point = [touch locationInView:nil];
            float pointX = screenWidth - point.x, pointY = point.y;
            BOOL inAirRange = airEnabled && (
                                             (invertAir && pointY > screenHeight - airHeight) ||
                                             (!invertAir && pointY < airHeight)
                                            );
            if (inAirRange) {
                int idx;
                if (invertAir) {
                    idx = (screenHeight - pointY) / airIOHeight;
                } else {
                    idx = pointY / airIOHeight;
                }
                uint8_t airIdx[] = {5,4,3,2,1,0};
                buf.air[airIdx[idx]] = 1;
            } else {
                float pointPos = pointX / sliderIOWidth;
                bool isHalfUp = (screenHeight - pointY) / sliderIOHeight > 0.5;
                int idx = 2 * floorf(pointPos) + (isHalfUp && enableFullSlideSensorToggle.on ? 0 : 1);
                buf.slider[ idx ] = 0x80;
                NSLog(@"idx: %i", idx);
            }
        }
    }
    [self sendIoBuf:&buf];
}

-(void)hideStatus {
    pendingHideStatus = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self->connectStatusView.frame = CGRectMake(self->screenWidth, self->screenHeight * 0.1, 200.0, 50.0);
    }];
}
-(void)connected {
    connectStatusView.text = [[NSBundle mainBundle] localizedStringForKey:@"Connected" value:@"" table:nil];
    [self performSelector:@selector(hideStatus) withObject:nil afterDelay:3];
    pendingHideStatus = YES;
    
    uint8_t airConf[] = {4, 'A', 'I', 'R', airEnabled};
    NSData *airConfData = [NSData dataWithBytes:airConf length:sizeof(airConf)];
    [server BroadcastData:airConfData];
}
-(void)disconnected {
    if (pendingHideStatus) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideStatus) object:nil];
    }
    connectStatusView.text = [[NSBundle mainBundle] localizedStringForKey:@"Not connected" value:@"" table:nil];
    [UIView animateWithDuration:0.3 animations:^{
        self->connectStatusView.frame = CGRectMake(self->screenWidth - 200.0, self->screenHeight * 0.1, 200.0, 50.0);
    }];
    if (autoPopMenu) {
        [self openFunc];
    }
}
-(void)becomeInactive {
    struct ioBuf buf = {0};
    [self sendIoBuf:&buf];
}
-(void)becomeActive {
    [self loadPrefs];
}

@end
