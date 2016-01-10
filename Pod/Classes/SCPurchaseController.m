//
//  SCPurchaseController.m
//  C2CallPhone
//
//  Created by Michael Knecht on 25.06.13.
//  Copyright 2013,2014 C2Call GmbH. All rights reserved.
//
//
#import "SCPurchaseController.h"

#import <StoreKit/StoreKit.h>

#import "C2CallAppDelegate.h"
#import "SCStoreObserver.h"
#import "AlertUtil.h"
#import "debug.h"

@interface SCPurchaseController ()<SKProductsRequestDelegate> {
	SKProductsRequest			*productsRequest;
	SKProductsResponse			*productsResponse;
    SKProduct                   *selectedProduct;
}

@property(nonatomic, weak) IBOutlet	UIActivityIndicatorView		*activity;

@property(strong) SKProductsRequest			*productsRequest;
@property(strong) SKProductsResponse		*productsResponse;

-(void) queryProducts;

@end

@implementation SCPurchaseController
@synthesize productCellIdentifier, delegate, productsRequest, productsResponse;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (!self.productCellIdentifier) {
        self.productCellIdentifier = @"SCPurchaseControllerCell";
    }
    [self queryProducts];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Product Query

-(void) queryProducts
{
    NSSet *productlist = [SCStoreObserver instance].productIds;
    if (!productlist) {
        DLog(@"No products defined!");
        
        return;
    }
    
    [[C2CallAppDelegate appDelegate] waitIndicatorWithTitle:NSLocalizedString(@"Query Products", @"Product Request") andWaitMessage:nil];
    
	self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productlist];
	self.productsRequest.delegate = self;
	[self.productsRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	DLog(@"productsRequest:didReceiveResponse : %lu/%lu", [response.products count], (unsigned long)[response.invalidProductIdentifiers count]);
	[[C2CallAppDelegate appDelegate] waitIndicatorStop];
	self.productsResponse = response;
    
	[self.tableView reloadData];
	
    if ([productsResponse.products count] > 0) {
		[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
	}
}

- (void)requestDidFinish:(SKRequest *)request;
{
	[[C2CallAppDelegate appDelegate] waitIndicatorStop];
	DLog(@"requestDidFinish : %lu", (unsigned long)[productsResponse.products count]);
    
}
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error;
{
	[[C2CallAppDelegate appDelegate] waitIndicatorStop];
	DLog(@"didFailWithError : %@", error);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [productsResponse.products count];
}

-(void) configureCell:(UITableViewCell *) cell atIndexPath:(NSIndexPath *) indexPath
{
    SKProduct *p = [productsResponse.products objectAtIndex:indexPath.row];

    cell.textLabel.text = [p.localizedTitle stringByReplacingOccurrencesOfString:@"\"" withString:@""]; //p.localizedTitle;
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:p.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:p.price];
    
    cell.detailTextLabel.text = formattedString;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = self.productCellIdentifier?self.productCellIdentifier : @"Cell";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectedProduct = [productsResponse.products objectAtIndex:indexPath.row];
    if (self.delegate) {
        [delegate didSelectProduct:selectedProduct];
    }
}

-(IBAction)buy:(id)sender
{
    if ([[SKPaymentQueue defaultQueue].transactions count] > 0) {
		[AlertUtil showShowCreditInfo3];
		return;
	}
	
	if (!selectedProduct)
		return;
	
	SKMutablePayment *myPayment = [SKMutablePayment paymentWithProduct:selectedProduct];
	myPayment.quantity = 1;
	[[SKPaymentQueue defaultQueue] addPayment:myPayment];
	
	[[C2CallAppDelegate appDelegate] logEvent:@"AddCredit" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:selectedProduct.productIdentifier, @"ProductId",
                                                  nil]];

}

@end
