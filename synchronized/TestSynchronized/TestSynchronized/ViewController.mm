//
//  ViewController.m
//  TestSynchronized
//
//  Created by zhangqi on 12/5/2017.
//  Copyright © 2017 zhangqi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic,assign) int ticketsCounts;  // 票总张数
@property (nonatomic,strong) NSThread *sellThread1;  // 卖票线程1
@property (nonatomic,strong) NSThread *sellThread2; // 卖票线程2

@property (nonatomic,strong) NSLock *ticketsLock;

@property (nonatomic,strong) dispatch_queue_t phoneQueue;
@end

@implementation ViewController

- (dispatch_queue_t)phoneQueue
{
    if (!_phoneQueue) {
        _phoneQueue = dispatch_queue_create("phone_queue", DISPATCH_QUEUE_SERIAL);
    }
    return _phoneQueue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.ticketsCounts = 100;
    
//    self.sellThread1 = [[NSThread alloc] initWithTarget:self selector:@selector(sellWindow01_NotThreadSelf) object:nil];
//    self.sellThread2 = [[NSThread alloc] initWithTarget:self selector:@selector(sellWindow02_NotThreadSelf) object:nil];
//    NSLog(@"开始卖票..");
//    [self.sellThread1 start];
//    [self.sellThread2 start];
    
    self.sellThread1 = [[NSThread alloc] initWithTarget:self selector:@selector(sellWindow01) object:nil];
    self.sellThread2 = [[NSThread alloc] initWithTarget:self selector:@selector(sellWindow02) object:nil];
    NSLog(@"开始卖票..");
    [self.sellThread1 start];
    [self.sellThread2 start];
    
    
    self.ticketsLock = [[NSLock alloc] init];
}

- (void)sellWindow01_NotThreadSelf
{
    while (self.ticketsCounts) {

        if (self.ticketsCounts == 0) {
            [self.sellThread1 cancel];
            NSLog(@"window01: 票卖完了... ");
            return;
        }
        self.ticketsCounts -= 1;
        NSLog(@"window01 卖了一张票,剩余票数：%d ",self.ticketsCounts);
        usleep(1000*1000); // 休眠1s

    }

}

- (void)sellWindow02_NotThreadSelf
{
    while (self.ticketsCounts) {
        
        if (self.ticketsCounts == 0) {
            [self.sellThread1 cancel];
            NSLog(@"window02: 票卖完了... ");
            return;
        }
        self.ticketsCounts -= 1;
        NSLog(@"window02 卖了一张票,剩余票数：%d ",self.ticketsCounts);
        usleep(1000*1000); // 休眠1s
        
    }
    
}


- (void)sellWindow01
{

///* 同步代码块  */
//    @synchronized (self) {
//
//        while (self.ticketsCounts) {
//
//            if (self.ticketsCounts == 0) {
//                [self.sellThread1 cancel];
//                NSLog(@"window01: 票卖完了... ");
//                return;
//            }
//            self.ticketsCounts -= 1;
//            NSLog(@"window01 卖了一张票,剩余票数：%d ",self.ticketsCounts);
//            usleep(1000*1000); // 休眠1s
//
//        }
//
//    }
    
    
/** 加锁 **/
//    [self.ticketsLock lock];
//        while (self.ticketsCounts) {
//
//            if (self.ticketsCounts == 0) {
//                [self.sellThread1 cancel];
//                NSLog(@"window01: 票卖完了... ");
//                return;
//            }
//            self.ticketsCounts -= 1;
//            NSLog(@"window01 卖了一张票,剩余票数：%d ",self.ticketsCounts);
//            usleep(1000*1000); // 休眠1s
//
//        }
//    [self.ticketsLock unlock];
    
    
    /** 放入串行队列中 **/
    dispatch_async(self.phoneQueue, ^{
        while (self.ticketsCounts) {
            
            if (self.ticketsCounts == 0) {
                [self.sellThread1 cancel];
                NSLog(@"window01: 票卖完了... ");
                return;
            }
            self.ticketsCounts -= 1;
            NSLog(@"window01 卖了一张票,剩余票数：%d ",self.ticketsCounts);
            usleep(1000*1000); // 休眠1s
            
        }
    });
    

}

- (void)sellWindow02
{
///** 同步代码块  **/
//    @synchronized (self) {
//
//        while (self.ticketsCounts) {
//
//            if (self.ticketsCounts == 0) {
//                [self.sellThread2 cancel];
//                NSLog(@"window02: 票卖完了... ");
//                return;
//            }
//            self.ticketsCounts -= 1;
//            NSLog(@"window02 卖了一张票,剩余票数：%d ",self.ticketsCounts);
//            usleep(1000*1000); // 休眠1s
//
//        }
//    }
    

    
    
// /** 加锁 **/
//        [self.ticketsLock lock];
//        while (self.ticketsCounts) {
//
//            if (self.ticketsCounts == 0) {
//                [self.sellThread2 cancel];
//                NSLog(@"window02: 票卖完了... ");
//                return;
//            }
//            self.ticketsCounts -= 1;
//            NSLog(@"window02 卖了一张票,剩余票数：%d ",self.ticketsCounts);
//            usleep(1000*1000); // 休眠1s
//
//        }
//        [self.ticketsLock unlock];
    
    
    /** 放入串行队列中 **/
    
    dispatch_async(self.phoneQueue, ^{
        while (self.ticketsCounts) {

            if (self.ticketsCounts == 0) {
                [self.sellThread2 cancel];
                NSLog(@"window02: 票卖完了... ");
                return;
            }
            self.ticketsCounts -= 1;
            NSLog(@"window02 卖了一张票,剩余票数：%d ",self.ticketsCounts);
            usleep(1000*1000); // 休眠1s
        }
        
    });
    

}

/*
  触摸屏幕停止卖票
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.sellThread1 cancel];
    [self.sellThread2 cancel];
    NSLog(@"停止买票，现在剩余票数=%d",self.ticketsCounts);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
