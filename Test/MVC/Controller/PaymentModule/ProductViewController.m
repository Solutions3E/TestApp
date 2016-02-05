//
//  ProductViewController.m
//  Test
//
//  Created by Admin on 05/02/16.
//  Copyright © 2016 3E. All rights reserved.
//

#import "ProductViewController.h"
#import "ProductCollectionViewCell.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface ProductViewController () <UICollectionViewDataSource, UICollectionViewDelegate> {
    NSArray *productImages;
}
@property (weak, nonatomic) IBOutlet UICollectionView *productCollectionView;
- (IBAction)btnAction_logOut:(id)sender;

@end

@implementation ProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    productImages = [NSArray arrayWithObjects: @"Product1", @"Product2", @"Product3", @"Product4", @"Product5", @"Product6", @"Product7", @"Product8", @"Product9", @"Product10", nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)logOutFromFB {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
}

//UICollectionViewDataSource - @required
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return productImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProductCollectionViewCell *productCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ProductCollectionViewCell" forIndexPath:indexPath];
    productCell.imgview_product.image = [UIImage imageNamed: [productImages objectAtIndex:indexPath.row]];
    [productCell layoutIfNeeded];
    return productCell;
}

//UICollectionViewDelegate - @optional
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"order" sender:nil];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int numberOfCellInRow  = 2;
    int padding  = 15;
    CGFloat collectionCellWidth  = (self.productCollectionView.frame.size.width/numberOfCellInRow) - padding ;
    CGSize size =  CGSizeMake(collectionCellWidth ,  collectionCellWidth);
    return size;
}

- (IBAction)btnAction_logOut:(id)sender {
    [self logOutFromFB];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
