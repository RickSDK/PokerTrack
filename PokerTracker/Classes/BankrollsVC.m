//
//  BankrollsVC.m
//  PokerTracker
//
//  Created by Rick Medved on 7/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BankrollsVC.h"
#import "MoneyPickerVC.h"
#import "ProjectFunctions.h"
#import "CoreDataLib.h"
#import "ListPicker.h"
#import "NSDate+ATTDate.h"
#import "QuadFieldTableViewCell.h"
#import "NSArray+ATTArray.h"
#import "UIColor+ATTColor.h"
#import "DatePickerViewController.h"
#import "NSString+ATTString.h"

@implementation BankrollsVC
@synthesize managedObjectContext, callBackViewController, bankrollLabel, bankrollButton, menuOption, mainTableView;
@synthesize logItems, rowNum, deleteButton, editAmountButton, editDateButton, amountString, createdDate, transType, indexpathRow, logObjects, selectedFlg;
@synthesize bankrollSmallLabel, showAllButton, bankrollSwitch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction) withdrawButtonClicked:(id)sender
{
    self.menuOption=2;
    MoneyPickerVC *detailViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.callBackViewController = self;
    detailViewController.titleLabel = @"Withdraw Money";
	[self.navigationController pushViewController:detailViewController animated:YES];
    
}
- (IBAction) depositButtonClicked:(id)sender
{
    self.menuOption=3;
    MoneyPickerVC *detailViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.callBackViewController = self;
    detailViewController.titleLabel = @"Deposit Money";
	[self.navigationController pushViewController:detailViewController animated:YES];
    
}

- (IBAction) bankrollButtonClicked:(id)sender
{
    self.menuOption=1; 
	ListPicker *localViewController = [[ListPicker alloc] initWithNibName:@"ListPicker" bundle:nil];
	localViewController.callBackViewController=self;
	localViewController.managedObjectContext = managedObjectContext;
	localViewController.initialDateValue = [NSString stringWithFormat:@"%@", bankrollButton.titleLabel.text];
	localViewController.titleLabel = @"Bankroll";
	localViewController.selectedList = 0;
    localViewController.maxFieldLength=10;
	localViewController.selectionList = [CoreDataLib getFieldList:@"Bankroll" mOC:managedObjectContext addAllTypesFlg:NO]; 
	localViewController.allowEditing=YES;
	[self.navigationController pushViewController:localViewController animated:YES];
    
}

#pragma mark - View lifecycle

-(void)selectButtonClicked:(id)sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(selectedFlg && indexpathRow==indexPath.row) {
        deleteButton.alpha=0;
        editAmountButton.alpha=0;
        editDateButton.alpha=0;
        [mainTableView reloadData];
        self.selectedFlg=NO;
        return;
    }
    self.selectedFlg=YES;
    self.indexpathRow=(int)indexPath.row;
    NSString *valueString = [logItems objectAtIndex:indexPath.row];
    NSArray *items = [valueString componentsSeparatedByString:@"|"];
    if([items count]>2) {
        NSString *initialAmount = [items objectAtIndex:2];
        initialAmount = [initialAmount stringByReplacingOccurrencesOfString:@"(" withString:@""];
        self.amountString = [initialAmount stringByReplacingOccurrencesOfString:@")" withString:@""];
        self.transType = [items objectAtIndex:0];
        self.createdDate = [items objectAtIndex:1];
    }

	self.rowNum = (int)indexPath.row;
    deleteButton.alpha=1;
    editAmountButton.alpha=1;
    editDateButton.alpha=1;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}

- (IBAction) showAllButtonClicked:(id)sender {
    [ProjectFunctions setUserDefaultValue:@"Default" forKey:@"bankrollDefault"];
	[self.navigationController popViewControllerAnimated:YES];
    
}


-(void)updateBankrollDB
{
    NSString *bankrollName = [ProjectFunctions getUserDefaultValue:@"bankrollDefault"];
    if([bankrollName length]==0)
        [ProjectFunctions setUserDefaultValue:@"Default" forKey:@"bankrollDefault"];
    
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"name = %@", [ProjectFunctions getUserDefaultValue:@"bankrollDefault"]];
    NSArray *items1 = [CoreDataLib selectRowsFromEntity:@"BANKROLL" predicate:predicate1 sortColumn:nil mOC:managedObjectContext ascendingFlg:NO];
    
    if([items1 count]==0) {
        [ProjectFunctions setUserDefaultValue:@"0" forKey:@"defaultBankroll"];
        [ProjectFunctions updateMoneyLabel:bankrollLabel money:[[ProjectFunctions getUserDefaultValue:@"defaultBankroll"] intValue]];
       [CoreDataLib insertAttributeManagedObject:@"BANKROLL" valueList:[NSArray arrayWithObjects:[ProjectFunctions getUserDefaultValue:@"bankrollDefault"], nil] mOC:managedObjectContext];
    }
   
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = 'bankroll' AND name = %@", [ProjectFunctions getUserDefaultValue:@"bankrollDefault"]];
    NSArray *items = [CoreDataLib selectRowsFromEntity:@"EXTRA2" predicate:predicate sortColumn:nil mOC:managedObjectContext ascendingFlg:NO];
    
    if([items count]==0) {
        NSArray *values = [NSArray arrayWithObjects:@"bankroll", [ProjectFunctions getUserDefaultValue:@"bankrollDefault"], [ProjectFunctions getUserDefaultValue:@"defaultBankroll"], [[NSDate date] convertDateToStringWithFormat:nil], nil];
        [CoreDataLib insertManagedObjectForEntity:@"EXTRA2" valueList:values mOC:managedObjectContext];
    } else {
        NSManagedObject *mo = [items objectAtIndex:0];
        [ProjectFunctions setUserDefaultValue:[mo valueForKey:@"attrib_01"] forKey:@"defaultBankroll"];
    }
    
    [bankrollButton setTitle:[NSString stringWithFormat:@"%@", [ProjectFunctions getUserDefaultValue:@"bankrollDefault"]] forState:UIControlStateNormal];

    int money = [[ProjectFunctions getUserDefaultValue:@"defaultBankroll"] intValue];
    [ProjectFunctions updateMoneyLabel:bankrollLabel money:money];
    bankrollSmallLabel.text = [ProjectFunctions convertNumberToMoneyString:money];
    if(money<10000)
        bankrollSmallLabel.alpha = 0;
    
    
    [logItems removeAllObjects];
    [logObjects removeAllObjects];
    NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"type = 'bankrollLog' AND name = %@", [ProjectFunctions getUserDefaultValue:@"bankrollDefault"]];
    NSArray *items3 = [CoreDataLib selectRowsFromEntity:@"EXTRA2" predicate:predicate3 sortColumn:@"created" mOC:managedObjectContext ascendingFlg:YES];
    for(NSManagedObject *mo in items3) {
        [logObjects addObject:mo];
        int amount = [[mo valueForKey:@"attrib_01"] intValue];
        NSDate *created = [mo valueForKey:@"created"];
        [logItems addObject:[NSString stringWithFormat:@"%@|%@|%@", (amount>=0)?@"Deposit":@"Withdraw", [created convertDateToStringWithFormat:nil], [ProjectFunctions convertIntToMoneyString:amount]]];
    }
    [mainTableView reloadData];
}

- (IBAction) editAmountButtonClicked:(id)sender
{
    self.menuOption=4;
    MoneyPickerVC *detailViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.callBackViewController = self;
    detailViewController.initialDateValue=amountString;
    detailViewController.titleLabel = @"Transaction Amount";
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) editDateButtonClicked:(id)sender
{
    self.menuOption=5;
    DatePickerViewController *localViewController = [[DatePickerViewController alloc] init];
    localViewController.labelString = @"Transaction Date";
    [localViewController setCallBackViewController:self];
    localViewController.initialDateValue = nil;
    localViewController.allowClearField = NO;
    localViewController.dateOnlyMode = NO;
    localViewController.refusePastDates = NO;
    localViewController.initialValueString = createdDate;
    [self.navigationController pushViewController:localViewController animated:YES];
}


- (IBAction) deleteButtonClicked:(id)sender
{
    deleteButton.alpha=0;
    editAmountButton.alpha=0;
    editDateButton.alpha=0;

    NSPredicate *predicate3 = [NSPredicate predicateWithFormat:@"type = 'bankrollLog' AND name = %@", [ProjectFunctions getUserDefaultValue:@"bankrollDefault"]];
    NSArray *items3 = [CoreDataLib selectRowsFromEntity:@"EXTRA2" predicate:predicate3 sortColumn:@"created" mOC:managedObjectContext ascendingFlg:YES];
    if([items3 count]>rowNum) {
        NSManagedObject *mo = [items3 objectAtIndex:rowNum];
        [managedObjectContext deleteObject:mo];
        [managedObjectContext save:nil];
        [logItems removeObjectAtIndex:rowNum];
        [mainTableView reloadData];

    }
}

-(void)setButtonClicked:(id)sender {
    self.menuOption=11;
    MoneyPickerVC *detailViewController = [[MoneyPickerVC alloc] initWithNibName:@"MoneyPickerVC" bundle:nil];
	detailViewController.managedObjectContext = managedObjectContext;
	detailViewController.callBackViewController = self;
    detailViewController.titleLabel = @"Set Bankroll Amount";
	[self.navigationController pushViewController:detailViewController animated:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Bankroll"];
    
    [self.mainTableView setBackgroundView:nil];

    logItems = [[NSMutableArray alloc] initWithCapacity:500];
    logObjects = [[NSMutableArray alloc] initWithCapacity:500];
    
    [self updateBankrollDB];
    
    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithTitle:@"Set Amount" style:UIBarButtonItemStylePlain target:self action:@selector(setButtonClicked:)];
	self.navigationItem.rightBarButtonItem = moreButton;
    
    deleteButton.alpha=0;
    editAmountButton.alpha=0;
    editDateButton.alpha=0;


    int numBanks = [[ProjectFunctions getUserDefaultValue:@"numBanks"] intValue];
    
    showAllButton.alpha=1;
    
    if(numBanks==0) {
        showAllButton.alpha=0;
    }

	if ([@"Y" isEqualToString:[ProjectFunctions getUserDefaultValue:@"bankrollSwitch"]])
		self.bankrollSwitch.on=YES;
	else
		self.bankrollSwitch.on=NO;
		

    // Do any additional setup after loading the view from its nib.
}

- (IBAction) bankrollSwitchClicked:(id)sender {
	if(self.bankrollSwitch.on)
		[ProjectFunctions setUserDefaultValue:@"Y" forKey:@"bankrollSwitch"];
	else
		[ProjectFunctions setUserDefaultValue:@"" forKey:@"bankrollSwitch"];
}



-(void)createBankrollLog:(int)amount bankrollAmount:(int)bankrollAmount
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type = 'bankroll' AND name = %@", [ProjectFunctions getUserDefaultValue:@"bankrollDefault"]];
    NSArray *items = [CoreDataLib selectRowsFromEntity:@"EXTRA2" predicate:predicate sortColumn:nil mOC:managedObjectContext ascendingFlg:NO];
    if([items count]>0) {
        NSManagedObject *mo = [items objectAtIndex:0];
        [mo setValue:[NSNumber numberWithInt:bankrollAmount] forKey:@"attrib_01"];
        NSLog(@"Updating number to: %d", bankrollAmount);
    }
    NSLog(@"Inserting record of: %d", amount);
    NSArray *values = [NSArray arrayWithObjects:@"bankrollLog", [ProjectFunctions getUserDefaultValue:@"bankrollDefault"], [NSString stringWithFormat:@"%d", amount], [[NSDate date] convertDateToStringWithFormat:nil], nil];
    [CoreDataLib insertManagedObjectForEntity:@"EXTRA2" valueList:values mOC:managedObjectContext];
   
}

-(void) setReturningValue:(NSString *) value {
	if(menuOption==1) {
        [ProjectFunctions setUserDefaultValue:value forKey:@"bankrollDefault"];
//        int bankrollAmount = [[ProjectFunctions getUserDefaultValue:@"defaultBankroll"] intValue];
//        [ProjectFunctions setUserDefaultValue:value forKey:@"defaultBankroll"];
    }
    if(menuOption==2) {
        int amount = [value intValue];
        int bankrollAmount = [[ProjectFunctions getUserDefaultValue:@"defaultBankroll"] intValue];
        bankrollAmount -= amount;
        [self createBankrollLog:(amount*-1) bankrollAmount:bankrollAmount];
        
    }
    if(menuOption==3) {
        int amount = [value intValue];
        int bankrollAmount = [[ProjectFunctions getUserDefaultValue:@"defaultBankroll"] intValue];
        bankrollAmount += amount;

        [self createBankrollLog:amount bankrollAmount:bankrollAmount];
    }
    if(menuOption==4) {
        NSManagedObject *mo = [logObjects objectAtIndex:indexpathRow];
        int valueAmount = [value intValue];
        if([@"Withdraw" isEqualToString:transType])
            valueAmount *=-1;
        
        [mo setValue:[NSNumber numberWithInt:valueAmount] forKey:@"attrib_01"];
        [managedObjectContext save:nil];
        deleteButton.alpha=0;
        editAmountButton.alpha=0;
        editDateButton.alpha=0;
        [self updateBankrollDB];
    }
    if(menuOption==5) { // edit date
        NSManagedObject *mo = [logObjects objectAtIndex:indexpathRow];
        [mo setValue:[value convertStringToDateWithFormat:nil] forKey:@"created"];
        [managedObjectContext save:nil];
        deleteButton.alpha=0;
        editAmountButton.alpha=0;
        editDateButton.alpha=0;
        [self updateBankrollDB];
    }
    if(menuOption==11) {
        
        int bankrollAmount = [[ProjectFunctions getUserDefaultValue:@"defaultBankroll"] intValue];
        int newAmount = [value intValue];
        int dif = newAmount-bankrollAmount;
        [self createBankrollLog:dif bankrollAmount:newAmount];
        
    }

    
    [self updateBankrollDB];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [logItems count];	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%ldRow%ld", (long)indexPath.section, (long)indexPath.row];

    QuadFieldTableViewCell *cell = (QuadFieldTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[QuadFieldTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.backgroundColor = [UIColor ATTFaintBlue];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;

    NSArray *components = [[logItems objectAtIndex:indexPath.row] componentsSeparatedByString:@"|"];
    cell.aa.text = [components stringAtIndex:0];
    cell.bb.text = [components stringAtIndex:1];
    cell.cc.text = [components stringAtIndex:2];

    self.selectedFlg=NO;
    
    return cell;
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
