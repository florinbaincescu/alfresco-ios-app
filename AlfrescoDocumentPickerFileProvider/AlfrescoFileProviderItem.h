/*******************************************************************************
 * Copyright (C) 2005-2017 Alfresco Software Limited.
 *
 * This file is part of the Alfresco Mobile iOS App.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 ******************************************************************************/

#import <FileProvider/FileProvider.h>
@class UserAccount;
@class FileProviderAccountInfo;
@class RealmSyncNodeInfo;

@interface AlfrescoFileProviderItem : NSObject <NSFileProviderItem>

@property (nonatomic, readonly, copy) NSString *parentItemIdentifier;
@property (nonatomic, readonly, copy) NSString *itemIdentifier;
@property (nonatomic, readonly, copy) NSString *filename;
@property (nonatomic, readonly) BOOL isDownloaded;

- (instancetype)initWithUserAccount:(UserAccount *)account;
- (instancetype)initWithAccountInfo:(FileProviderAccountInfo *)accountInfo;
- (instancetype)initWithAlfrescoNode:(AlfrescoNode *)node parentItemIdentifier:(NSFileProviderItemIdentifier)parentItemIdentifier;
- (instancetype)initWithSite:(AlfrescoSite *)site parentItemIdentifier:(NSFileProviderItemIdentifier)parentItemIdentifier;
- (instancetype)initWithSyncedNode:(RealmSyncNodeInfo *)node parentItemIdentifier:(NSFileProviderItemIdentifier)parentItemIdentifier;

@end
