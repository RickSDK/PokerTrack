//
//  ForumCategoryVC.m
//  PokerTracker
//
//  Created by Rick Medved on 6/3/13.
//
//

#import "ForumCategoryVC.h"
#import "ForumPostVC.h"
#import "ForumCreateVC.h"
#import "WebServicesFunctions.h"
#import "ProjectFunctions.h"
#import "ForumCell.h"

@interface ForumCategoryVC ()

@end

@implementation ForumCategoryVC

@synthesize forumPostings, mainTableView, activityIndicator, headertextView, managedObjectContext, category;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = [NSString stringWithFormat:@"cellIdentifierSection%dRow%d", (int)indexPath.section, (int)indexPath.row];
    ForumCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell==nil)
	    cell = [[ForumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    cell.repliesLabel.alpha=1;
    cell.repliesNumber.alpha=1;
    cell.bodyLabel.alpha=1;
    cell.userLabel.alpha=1;
    cell.dateLabel.alpha=1;
    NSString *post = [self.forumPostings objectAtIndex:indexPath.row];
    NSArray *parts = [post componentsSeparatedByString:@"|"];
    if([parts count]>9) {
        cell.titleLabel.text=[parts objectAtIndex:3];
        cell.userLabel.text=[parts objectAtIndex:5];
        cell.dateLabel.text=[parts objectAtIndex:7];
        int minutes = [[parts objectAtIndex:6] intValue];
  //      int replies = [[parts objectAtIndex:9] intValue];
 //       if(replies>0) {
            cell.repliesNumber.text=[parts objectAtIndex:9];
            cell.mainImg.image = nil;
   //     } else {
     //       cell.repliesLabel.alpha=0;
       //     cell.repliesNumber.alpha=0;
         //   cell.mainImg.image = [UIImage imageNamed:@"IconImg.png"];
       // }
        if(minutes<720)
            cell.dateLabel.text=@"Today";
        cell.bodyLabel.text=[parts objectAtIndex:8];
        if([@"Y" isEqualToString:[parts objectAtIndex:4]])
           cell.mainImg.image = [UIImage imageNamed:@"new.png"];
    }
	cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.forumPostings count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ForumPostVC *detailViewController = [[ForumPostVC alloc] initWithNibName:@"ForumPostVC" bundle:nil];
    detailViewController.managedObjectContext = self.managedObjectContext;
    detailViewController.category=self.category;
    detailViewController.postStr=[self.forumPostings objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)createPressed:(id)sender {
    if([ProjectFunctions isLiteVersion]) {
        [ProjectFunctions showAlertPopup:@"Notice" message:@"Users of Lite version cannot post messages. Please upgrade!"];
        return;
    }
    ForumCreateVC *detailViewController = [[ForumCreateVC alloc] initWithNibName:@"ForumCreateVC" bundle:nil];
    detailViewController.category=self.category;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

-(void)loadForum
{
	@autoreleasepool {
    
        [self.forumPostings removeAllObjects];
        
        
        
        NSArray *nameList = [NSArray arrayWithObjects:@"Username", @"Password", @"type", @"category", nil];
	NSString *username = [ProjectFunctions getUserDefaultValue:@"userName"];
	NSString *password = [ProjectFunctions getUserDefaultValue:@"password"];
	NSArray *valueList = [NSArray arrayWithObjects:username, password, @"Category", [NSString stringWithFormat:@"%d", self.category], nil];
        
 	NSString *webAddr = @"http://www.appdigity.com/poker/forumGetHeadlines.php";
	NSString *responseStr = [WebServicesFunctions getResponseFromServerUsingPost:webAddr fieldList:nameList valueList:valueList];
        NSLog(@"responseStr: %@", responseStr);
        if([WebServicesFunctions validateStandardResponse:responseStr delegate:nil]) {
            NSArray *parts1 = [responseStr componentsSeparatedByString:@"<br>"];
            if([parts1 count]>1) {
                    NSArray *postings = [[parts1 objectAtIndex:1] componentsSeparatedByString:@"<b>"];
                    [self.forumPostings addObjectsFromArray:postings];
            }
        }
        [self.forumPostings removeLastObject];
 	
	[self.activityIndicator stopAnimating];
        
        [self.mainTableView reloadData];
	}
}

-(void)refreshPage {
    [self.activityIndicator startAnimating];
	[self performSelectorInBackground:@selector(loadForum) withObject:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if([self respondsToSelector:@selector(edgesForExtendedLayout)])
        [self setEdgesForExtendedLayout:UIRectEdgeBottom];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return CGFLOAT_MIN;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.forumPostings = [[NSMutableArray alloc] initWithCapacity:4];
    

    NSArray *titles = [NSArray arrayWithObjects:@"Announcements", @"General", @"Strategy", @"Bad Beats", nil];
    [self setTitle:[titles objectAtIndex:self.category]];
    
    if(self.category==0)
        self.headertextView.text = @"Any important announcements about this app will be posted here";
    if(self.category==1)
        self.headertextView.text = @"Feel free to post any general questions or comments about the app or poker in general here.";
    if(self.category==2)
        self.headertextView.text = @"Care to share or comment on poker strategies? Post here to start the discussion.";
    if(self.category==3)
        self.headertextView.text = @"Let us know about your latest bad beat stories here.";

    NSString *emailAddress = [ProjectFunctions getUserDefaultValue:@"emailAddress"];
    
    if(self.category>0 || [@"rickmedved@hotmail.com" isEqualToString:emailAddress] || [@"robbmedved@yahoo.com" isEqualToString:emailAddress]) {
    
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createPressed:)];
        self.navigationItem.rightBarButtonItem = addButton;
    }
    
    [self refreshPage];
    
    // Do any additional setup after loading the view from its nib.
}





@end
