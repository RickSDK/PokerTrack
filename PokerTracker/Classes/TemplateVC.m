//
//  TemplateVC.m
//  PokerTracker
//
//  Created by Rick Medved on 1/21/16.
//
//

#import "TemplateVC.h"
#import "AnalysisDetailsVC.h"

@interface TemplateVC ()

@end

@implementation TemplateVC

-(BOOL)isPokerZilla {
	return [ProjectFunctions isPokerZilla];
}

-(float)screenWidth {
	return [[UIScreen mainScreen] bounds].size.width;
}

-(float)screenHeight {
	return [[UIScreen mainScreen] bounds].size.height;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.webServiceElements = [[NSMutableArray alloc] init];
	self.textFieldElements = [[NSMutableArray alloc] init];
	self.mainArray = [[NSMutableArray alloc] init];
	
	self.popupView.hidden=YES;
	self.bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, [self screenWidth], [self screenHeight])];
	self.bgImageView.image = [UIImage imageNamed:@"greenFelt.png"];
	[self.view addSubview:self.bgImageView];
	[self.view sendSubviewToBack:self.bgImageView];
	
	self.webServiceView = [[WebServiceView alloc] initWithFrame:CGRectMake(36, 203, 257, 178)];
	[self.view addSubview:self.webServiceView];
	
	self.navigationItem.leftBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAArrowLeft] target:self action:@selector(backButtonClicked)];

	self.startDegree=0;
	[self.mainTableView setBackgroundView:nil];
	[self.ptpGameSegment turnIntoGameSegment];
	[self.gameSummaryView addTarget:@selector(gotoAnalysis) target:self];
	int currentMinYear = [[ProjectFunctions getUserDefaultValue:@"minYear2"] intValue];
	[self.yearChangeView setYear:-1 min:currentMinYear];
	[self.yearChangeView addTargetSelector:@selector(calculateStats) target:self];
}

-(void)saveDatabase {
	NSError *error;
	[self.managedObjectContext save:&error];
	if(error) {
		NSLog(@"%@", error.description);
		NSLog(@"%@", error.debugDescription);
		[ProjectFunctions showAlertPopup:@"Database Error" message:error.localizedDescription];
	}
}

-(void)populatePopupWithTitle:(NSString *)title text:(NSString *)text {
	self.popupView.titleLabel.text = title;
	self.popupView.textView.text = text;
	self.popupView.textView.hidden=NO;
	self.popupView.hidden=NO;
}

-(void)addHomeButton {
	self.navigationItem.rightBarButtonItem = [ProjectFunctions UIBarButtonItemWithIcon:[NSString fontAwesomeIconStringForEnum:FAHome] target:self action:@selector(mainMenuButtonClicked:)];
}

-(void)mainMenuButtonClicked:(id)sender {
	[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
}

-(void)gotoAnalysis {
	AnalysisDetailsVC *detailViewController = [[AnalysisDetailsVC alloc] initWithNibName:@"AnalysisDetailsVC" bundle:nil];
	detailViewController.managedObjectContext = self.managedObjectContext;
	[self.navigationController pushViewController:detailViewController animated:YES];
}

- (IBAction) ptpGameSegmentChanged: (id) sender {
	[self.ptpGameSegment gameSegmentChanged];
	[self calculateStats];
}

-(void)calculateStats {
	
}

-(void)backButtonClicked {
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if([self respondsToSelector:@selector(edgesForExtendedLayout)])
		[self setEdgesForExtendedLayout:UIRectEdgeBottom];
}

- (void)viewWillTransitionToSize:(CGSize)size
	   withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
	self.bgImageView.frame = CGRectMake(0, 0, size.width, size.height+44);
}

- (IBAction) xButtonClicked: (id) sender {
	self.popupView.hidden=YES;
	[self.mainTextfield resignFirstResponder];
}

-(void)popupButtonClicked {
	self.popupView.hidden=!self.popupView.hidden;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if(cell==nil)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	cell.textLabel.text=@"test";
	cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
	cell.accessoryType= UITableViewCellAccessoryNone;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.mainArray count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

-(void)startWebService:(SEL)aSelector message:(NSString *)message {
	for(UIControl *button in self.webServiceElements)
		button.enabled=NO;
	[self resignResponders];
	
	[self.mainArray removeAllObjects];
	self.mainTableView.alpha=0;
	[self.webServiceView startWithTitle:message];
	[self performSelectorInBackground:aSelector withObject:nil];
}

-(void)stopWebService {
	for(UIControl *button in self.webServiceElements)
		button.enabled=YES;
	[self.webServiceView stop];
	[self.mainTableView reloadData];
	self.mainTableView.alpha=1;
}

-(void)resignResponders {
	for(UIControl *textField in self.textFieldElements)
		[textField resignFirstResponder];
}

- (IBAction) segmentChanged: (id) sender {
	[self.mainSegment changeSegment];
}


@end
