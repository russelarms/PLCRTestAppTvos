//
//  ViewController.m
//  CarthagePLCR
//
//  Created by Руслан Урмеев on 27.05.2020.
//  Copyright © 2020 Ruslan Urmeev. All rights reserved.
//

#import "ViewController.h"
#import "MSCrash.h"
#import <objc/runtime.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITableView *table;
@property NSArray<MSCrash *> *allCrashes;

@end

@implementation ViewController

- (void)crash {
    @throw [NSException exceptionWithName:NSGenericException reason:@"An uncaught exception! SCREAM."
    userInfo:@{NSLocalizedDescriptionKey: @"I'm in your program, catching your exceptions!"}];
}


- (void)viewDidLoad {
  [super viewDidLoad];
//  [self crash];

  int numClasses;
  Class *classes = NULL;

  classes = NULL;
  numClasses = objc_getClassList(NULL, 0);

  if (numClasses > 0 )
  {
      classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
      numClasses = objc_getClassList(classes, numClasses);
      for (int i = 0; i < numClasses; i++) {
        Class someClass = classes[i];
        Class superClass = class_getSuperclass(someClass);
        if (superClass == [MSCrash class] && someClass != [MSCrash class]){
          [MSCrash registerCrash:[someClass alloc]];
        }
      }
      free(classes);
  }

  NSArray *crashes = [MSCrash allCrashes];

  NSSortDescriptor *sortDescriptor;
  sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title"
                                             ascending:YES];
  _allCrashes = [crashes sortedArrayUsingDescriptors:@[sortDescriptor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  static NSString *cellId = @"SimpleTableId";

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (cell == nil) {
      cell = [[UITableViewCell alloc]initWithStyle:
              UITableViewCellStyleDefault reuseIdentifier:cellId];
  }
  MSCrash *mscrash = [[self allCrashes] objectAtIndex:indexPath.row];
  [cell.textLabel setText:[mscrash title]];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  MSCrash *mscrash = [[self allCrashes] objectAtIndex:indexPath.row];
  [mscrash crash];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
  return [_allCrashes count];
}

@end
