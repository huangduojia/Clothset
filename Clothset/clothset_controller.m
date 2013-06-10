//
//  clothset_controller.m
//  Clothset
//
//  Created by huang on 13-6-10.
//  Copyright (c) 2013年 huang. All rights reserved.
//

#import "clothset_controller.h"

@interface clothset_controller ()

@end

@implementation clothset_controller

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
   // int i = 0;
    NSString *databasepath;
    cellstring = [[NSMutableArray alloc]init];
    // NSString *temp_string;
    sqlite3 *database;
   // listdata = [[NSMutableArray alloc] init];
    NSArray *arrayOfPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [arrayOfPaths objectAtIndex:0];
    sqlite3_stmt *stmt;
    //  filmstring = [[NSMutableArray alloc] init];
    //    NSMutableArray *temp_array = [[NSMutableArray alloc] init];
    NSString *sql = @"SELECT IMAGE,BRAND FROM CLOTHSET";  //sql 语句
    databasepath = [path stringByAppendingPathComponent:@"clothset.db"];
    // NSLog(@"%@",databasepath);
    if (sqlite3_open([databasepath UTF8String], &database)==SQLITE_OK)
    {
      //  NSLog(@"打开数据库成功!");
        if (sqlite3_prepare_v2(database, [sql UTF8String], -1, &stmt, Nil) == SQLITE_OK)
        {
            
            while (sqlite3_step(stmt) == SQLITE_ROW)
            {
                //NSLog(@"%d",i);
                //i++;
                
                clothset_data *clothsetdata = [[clothset_data alloc]init];
                int bytes = sqlite3_column_bytes(stmt, 0);
                Byte *value = (Byte* )sqlite3_column_blob(stmt, 0);
                if( value != NULL && bytes != 0 ){
                    NSData *data = [NSData dataWithBytes:value length:bytes];
             //   NSData *data = sqlite3_column_blob(stmt, 0);
                clothsetdata.cloth = [UIImage imageWithData:data];
                 //   NSLog(@"读取数据库成功!");
                }
                NSString *select_brand = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(stmt, 1)];
                clothsetdata.brand = select_brand;
              //   NSLog(@"%@",select_brand);
                [cellstring addObject:clothsetdata];
                clothsetdata = nil;
            }
    
            sqlite3_close(database);
        }
    }
    
    NSLog(@"%d",cellstring.count);
    
    
}

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return [cellstring count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    */
    clothset_cell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"clothcell"];
    if (cell==nil) {
        cell=[[clothset_cell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"clothcell"];
    }
    
    clothset_data *clothdata = [[clothset_data alloc] init];
    clothdata = [cellstring objectAtIndex:indexPath.row];
    // NSLog(@"%@",filmdata_temp.ISO);
    cell.imageView.image = clothdata.cloth;
    cell.brand.text = clothdata.brand;
    NSLog(@"%@",cell.brand.text);
    clothdata = nil;
    
    //   NSLog(@"%@",filmdata.ISO);
    
    
    /*
     static NSString *CellIdentifier = @"Cell";
     
     UITableViewCell *cell = [tableView
     dequeueReusableCellWithIdentifier:CellIdentifier];
     if(cell == nil)
     {
     cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
     }
     NSUInteger row = [indexPath row];
     // cell.textLabel.text = [listdata objectAtIndex:row];
     cell.textLabel.text = @"lala";
     // Configure the cell...
     */
    return cell;
    // Configure the cell...
    
    //return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
