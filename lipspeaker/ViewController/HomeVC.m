//
//  HomeVC.m
//  lipspeaker
//
//  Created by Youmaru on 2019/11/15.
//  Copyright © 2019 Youmaru. All rights reserved.
//

#import "HomeVC.h"
#import "CollectVC.h"
#import "FileMgr.h"
#import "NetworkMgr.h"
#import "TestVC.h"
#import <Masonry/Masonry.h>

@interface HomeVC ()<UITextFieldDelegate>
@property(weak, nonatomic) UIButton *collect;
@property(weak, nonatomic) UITextField *textField;
@property(weak, nonatomic) UIButton *runTest;
@property(weak, nonatomic) UIButton *checkServer;
@property(weak, nonatomic) UILabel  *serverStatus;

@end

@implementation HomeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [self addCollectBtn];
    [self addTextFiled];
    [self addRunTestBtn];
    [self addCheckServerBtn];
    [self addServerStatusLabel];
    [self addClearBtn];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [self clcikCheckServer];
}



- (void)addCollectBtn {
    UIButton *collect = [[UIButton alloc] init];
    [collect setTitle:@"Collect Data" forState:UIControlStateNormal];
    [collect setBackgroundColor:[UIColor orangeColor]];
    collect.titleLabel.font = [UIFont systemFontOfSize:30];
    collect.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    collect.contentVerticalAlignment =  UIControlContentVerticalAlignmentCenter;
    [collect addTarget:self action:@selector(clickCollect) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:collect];
    self.collect = collect;
    
    __weak typeof(self) weakSelf = self;
    CGFloat offset = 60;
    [collect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view.mas_centerX);
        make.bottom.equalTo(weakSelf.view.mas_centerY).offset(-offset * 2);
        make.left.equalTo(weakSelf.view.mas_left).offset(offset);
        make.right.equalTo(weakSelf.view.mas_right).offset(-offset);
        make.height.equalTo(@(offset));
    }];
}

- (void)addTextFiled {
    UITextField *textField = [[UITextField alloc] init];
    textField.text = @"192.168.123.169";
    textField.font = [UIFont systemFontOfSize:20];
    textField.textColor = [UIColor blackColor];
    textField.delegate = self;
    textField.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:textField];
    self.textField = textField;
    __weak typeof(self) weakSelf = self;
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view);
        make.right.equalTo(weakSelf.view);
        make.height.equalTo(weakSelf.collect);
        make.bottom.equalTo(weakSelf.collect.mas_top);
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason{
    [NetworkMgr sharedManager].baseURL = textField.text;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.textField endEditing:YES];
}

- (void)addRunTestBtn {
    UIButton *runTest = [[UIButton alloc] init];
    [runTest setTitle:@"Run Test" forState:UIControlStateNormal];
    [runTest setBackgroundColor:[UIColor orangeColor]];
    runTest.titleLabel.font = [UIFont systemFontOfSize:30];
    runTest.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    runTest.contentVerticalAlignment =  UIControlContentVerticalAlignmentCenter;
    [runTest addTarget:self action:@selector(clickTestRun) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:runTest];
    self.runTest = runTest;
    
    __weak typeof(self) weakSelf = self;
    CGFloat offset = 30;
    [runTest mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.collect);
        make.top.equalTo(weakSelf.collect.mas_bottom).offset(offset);
        make.width.equalTo(weakSelf.collect);
        make.height.equalTo(weakSelf.collect);
    }];

}


- (void)addCheckServerBtn {
    
    UIButton *checkServer = [[UIButton alloc] init];
    [checkServer setTitle:@"Check Server" forState:UIControlStateNormal];
    [checkServer setBackgroundColor:[UIColor orangeColor]];
    checkServer.titleLabel.font = [UIFont systemFontOfSize:30];
    checkServer.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    checkServer.contentVerticalAlignment =  UIControlContentVerticalAlignmentCenter;
    [checkServer addTarget:self action:@selector(clcikCheckServer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:checkServer];
    self.checkServer = checkServer;
    
    __weak typeof(self) weakSelf = self;
    CGFloat offset = 30;
    [checkServer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.runTest);
        make.top.equalTo(weakSelf.runTest.mas_bottom).offset(offset);
        make.width.equalTo(weakSelf.runTest);
        make.height.equalTo(weakSelf.runTest);
    }];
}

- (void)addServerStatusLabel{
    UILabel *serverLabel = [[UILabel alloc] init];
    serverLabel.textColor = [UIColor blackColor];
    serverLabel.text = @"Checking Server...";
    serverLabel.font = [UIFont systemFontOfSize:20];
    serverLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:serverLabel];
    __weak typeof(self) weakSelf = self;
    CGFloat offset = 30;
    self.serverStatus = serverLabel;
    [serverLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.checkServer);
        make.top.equalTo(weakSelf.checkServer.mas_bottom).offset(offset);
        make.width.equalTo(weakSelf.checkServer);
        make.height.equalTo(weakSelf.checkServer);
    }];
}

- (void)addClearBtn {
    UIButton *clear = [[UIButton alloc] init];
    [clear setTitle:@"Clear Cache" forState:UIControlStateNormal];
    [clear setBackgroundColor:[UIColor orangeColor]];
    clear.titleLabel.font = [UIFont systemFontOfSize:30];
    clear.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    clear.contentVerticalAlignment =  UIControlContentVerticalAlignmentCenter;
    [clear addTarget:self action:@selector(clickClearCache) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clear];
    
    
    __weak typeof(self) weakSelf = self;
    CGFloat offset = 30;
    [clear mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.checkServer);
        make.top.equalTo(weakSelf.serverStatus.mas_bottom).offset(offset);
        make.width.equalTo(weakSelf.checkServer);
        make.height.equalTo(weakSelf.checkServer);
    }];
}

- (void)clickCollect{
    CollectVC *collectVC = [[CollectVC alloc] init];
    [self.navigationController pushViewController:collectVC animated:YES];
}

- (void)clickTestRun{
    TestVC *collectVC = [[TestVC alloc] init];
    [self.navigationController pushViewController:collectVC animated:YES];
}

- (void)clcikCheckServer{
    self.serverStatus.text = @"Checking Server...";
    __weak typeof(self) weakSelf = self;
    [[NetworkMgr sharedManager] checkServerWithPara:@{} completeHandler:^(NSError * _Nonnull error, id  _Nonnull response) {
        if (error) {
            weakSelf.serverStatus.text = @"Can't find server";
        } else {
            NSDictionary *json = (NSDictionary *)response;
            weakSelf.serverStatus.text = json[@"msg"];
        }
    }];
}

- (void)clickClearCache{
    FileMgr *fMgr = [FileMgr shareMgr];
    [fMgr removeDir:[fMgr packagePath]];
    UIAlertController *alertView = [UIAlertController alertControllerWithTitle:@"" message:@"Done" preferredStyle:(UIAlertControllerStyleAlert)];
    __weak typeof(self) weakSelf = self;
    UIAlertAction *showAlert = [UIAlertAction actionWithTitle:@"OK" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {

        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alertView addAction:showAlert];
    [self presentViewController:alertView animated:YES completion:nil];
}


@end
