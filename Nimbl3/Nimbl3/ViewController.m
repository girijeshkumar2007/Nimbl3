//
//  ViewController.m
//  Nimbl3
//
//  Created by mac on 03/01/16.
//  Copyright © 2016 mac. All rights reserved.
//

#import "ViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "SVProgressHUD.h"

#define kScreenSize [UIScreen mainScreen].bounds.size
#define kNavHeight 64.0

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate>
{
    NSMutableArray *arrOfSurvy;
}
@property(nonatomic,strong) IBOutlet UICollectionView *collectionView;
@property(nonatomic,strong) IBOutlet UIButton *btnTakeASurvey;
@property(nonatomic,strong) IBOutlet UIPageControl *pageControl;

@end

@implementation ViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupView];
    [self getSurvayData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Public Methods

#pragma mark - Private Methods
-(void)setupView
{
    arrOfSurvy = [NSMutableArray array];
    [_btnTakeASurvey.layer setCornerRadius:15.0];
    _pageControl.transform = CGAffineTransformMakeRotation(M_PI_2);
}

#pragma mark - User Interface
-(IBAction)refreshButtonTap:(id)sender
{
    [self getSurvayData];
    
}
-(IBAction)menuButtonTap:(id)sender
{
    [self performSegueWithIdentifier:@"pushSegue" sender:nil];
}
-(IBAction)takeTheSurvayBtnTap:(id)sender
{
    [self performSegueWithIdentifier:@"pushSegue" sender:nil];
}

-(IBAction)pageControllValueChange:(id)sender
{
    
    [_collectionView setContentOffset:CGPointMake(0, (kScreenSize.height-kNavHeight)*_pageControl.currentPage) animated:YES];
}
#pragma mark - UICollectionViewDelegate FlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
   return CGSizeMake(kScreenSize.width, kScreenSize.height-kNavHeight);
}

#pragma mark - CollectionView DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return arrOfSurvy.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *survyCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"survyCell" forIndexPath:indexPath];
    UIImageView *imageView = (UIImageView*)[survyCell viewWithTag:10];
    UILabel *lblName = (UILabel*)[survyCell viewWithTag:11];
    UILabel *lblDescription = (UILabel*)[survyCell viewWithTag:12];
    
    NSDictionary *dic =[arrOfSurvy objectAtIndex:indexPath.row];
    NSString *coverpath = [dic objectForKey:@"cover_image_url"];
    NSString *title = [dic objectForKey:@"title"];
    NSString *description = [dic objectForKey:@"description"];

    imageView.image=nil;
    if (coverpath) {
        [imageView setImageWithURL:[NSURL URLWithString:coverpath]];
    }
    lblName.text=title;
    lblDescription.text=description;
    _pageControl.currentPage=indexPath.row;
    
    return survyCell;
}

#pragma mark - API Hit
-(void)getSurvayData{

    if([SVProgressHUD isVisible])
    {return;}
    
    [SVProgressHUD showWithStatus:@"Please Wait..."];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSURL *URL = [NSURL URLWithString:@"https://www-staging.usay.co/app/surveys.json?access_token=6eebeac3dd1dc9c97a06985b6480471211a777b39aa4d0e03747ce6acc4a3369"];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
#if TARGET_IPHONE_SIMULATOR
            NSLog(@"Error: %@", error);
#elif TARGET_OS_IPHONE
            NSString *hello = @"Hello, device!";
#else
            NSString *hello = @"Hello, unknown target!";
#endif
        } else {
            
#if TARGET_IPHONE_SIMULATOR
            NSLog(@"%@ %@", response, responseObject);
#elif TARGET_OS_IPHONE
            NSString *hello = @"Hello, device!";
#else
            NSString *hello = @"Hello, unknown target!";
#endif
            [arrOfSurvy removeAllObjects];
            [arrOfSurvy addObjectsFromArray:responseObject];
            _pageControl.numberOfPages=arrOfSurvy.count;
            [SVProgressHUD dismiss];
            [_collectionView reloadData];

        }
    }];
    [dataTask resume];
}

@end
