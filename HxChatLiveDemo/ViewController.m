//
//  ViewController.m
//  HxChatDemo
//
//  Created by 江南孤鹜 on 16/6/22.
//  Copyright © 2016年 Martin. All rights reserved.
//

#import "ViewController.h"
#import "ChatUIHelper.h"
#import "UserCacheManager.h"
#import "ChatViewController.h"
#import "UIViewController+HUD.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"环信+直播测试";
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
// 登录环信并打开单聊界面
- (IBAction)doChat:(id)sender {
    
    NSString *userName = @"martin1234";
    NSString *pwd = @"martin1234";
    
    // 登录之前要先注销之前的用户，否则重复登录会抛异常
    EMError *error = [[EMClient sharedClient] logout:YES];
    if (!error) {
        NSLog(@"退出成功");
    }
    
    [self showHudInView:self.view hint:@"正在登录，请稍等~"];
    [[EMClient sharedClient] asyncLoginWithUsername:userName password:pwd success:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideHud];
            // 保存用户信息
            [UserCacheManager saveInfo:userName imgUrl:@"http://avatar.csdn.net/A/2/1/1_mengmakies.jpg" nickName:userName];
            
            //设置是否自动登录
            [[EMClient sharedClient].options setIsAutoLogin:YES];
            
            [[ChatUIHelper shareHelper] asyncGroupFromServer];
            [[ChatUIHelper shareHelper] asyncConversationFromDB];
            [[ChatUIHelper shareHelper] asyncPushOptions];
            
            //发送自动登陆状态通知
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@([[EMClient sharedClient] isLoggedIn])];
            
            ChatViewController *chatVC = [[ChatViewController alloc] initWithConversationChatter:@"1432362535305065" conversationType:EMConversationTypeChatRoom];
            chatVC.title = @"小马直播间";
            [self.navigationController pushViewController:chatVC animated:YES];
        });
        
        
    } failure:^(EMError *aError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self hideHud];
            
            UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@""
                                                           message:aError.errorDescription
                                                          delegate:nil
                                                 cancelButtonTitle:@"ok"
                                                 otherButtonTitles:nil];
            [alert show];
            
            [self showHint:aError.errorDescription];
            NSLog(@"登录报错了：%@",aError.errorDescription);
        });
    }];
}

@end
