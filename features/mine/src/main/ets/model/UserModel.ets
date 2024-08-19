/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { resourceManager } from '@kit.LocalizationKit';
import { PreferenceManager } from '@ohos/datastore';
import { UserAccount } from '@ohos/login';
import { ContinueModel, EventTypeEnum, FileUtil, LazyDataSource, Logger, ObservedArray } from '@ohos/utils';
import { ProfileConstants } from '../constants/ProfileConstants';
import { UserNetFunc } from '../service/UserNetFunc';
import { Achieve } from './Achieve';
import { ActionEventData } from './ActionEventData';
import { LearningResource } from './LearningResource';
import { UserData } from './UserData';

const TAG = '[UserModeL]';

/**
 * TOAST message position
 */
const TOAST_POSITION: number = 360;
const LOGIN_USER: string = 'logged_user';

let resource: resourceManager.Resource = {
  bundleName: $r('app.string.failed_message').bundleName,
  moduleName: $r('app.string.failed_message').moduleName,
  id: $r('app.string.failed_message').id
};

export class UserModel {
  private funNetwork: UserNetFunc;
  private static instance: UserModel;
  private preferenceManager: PreferenceManager = PreferenceManager.getInstance();
  collectedIds: ObservedArray<string> = new ObservedArray();
  likedIds: ObservedArray<string> = new ObservedArray();
  learnedIds: ObservedArray<string> = new ObservedArray();
  private userDataForDis: UserData = new UserData();
  collectedDataSource: LazyDataSource<LearningResource> = new LazyDataSource();
  viewedDataSource: LazyDataSource<LearningResource> = new LazyDataSource();

  constructor() {
    this.funNetwork = new UserNetFunc();
    const eventHub: common.EventHub = (getContext(this) as common.UIAbilityContext).eventHub;
    eventHub.on(EventTypeEnum.COLLECTED, (eventData: ActionEventData): void => this.handleCollectEvent(eventData));
    eventHub.on(EventTypeEnum.LIKED, (eventData: ActionEventData): void => this.handleLikeEvent(eventData));
    eventHub.on(EventTypeEnum.LEARNING, (learningId: string): void => this.handleLearningEvent(learningId));
    eventHub.on(EventTypeEnum.VIEW, (resourceId: string): void => this.setViewsCount(resourceId));
  }

  public static getInstance(): UserModel {
    if (!UserModel.instance) {
      UserModel.instance = new UserModel();
    }
    return UserModel.instance;
  }

  showFailedToast() {
    getContext(this).resourceManager.getStringValue(resource).then(value => {
      promptAction.showToast({ message: value, bottom: TOAST_POSITION });
    });
  }

  reload(curTab: TabInfo): Promise<void> {
    switch (curTab) {
      case TabInfo.COLLECTED:
        return this.getCollectedResources();
      case TabInfo.VIEWED:
        return this.getViewedResources();
      case TabInfo.ACHIEVEMENT:
        return this.getUserAchievements();
    }
  }

  /**
   * Save UserAccount to Preference
   * @param userAccount
   */
  saveUserAccount(userAccount: UserAccount): void {
    this.preferenceManager.setValue<UserAccount>(LOGIN_USER, userAccount);
  }

  getUserAccount(): Promise<UserAccount | null> {
    return this.preferenceManager.getValue<UserAccount>(LOGIN_USER);
  }

  deleteUserAccount(): Promise<void> {
    AppStorage.set('user', null);
    AppStorage.set('userId', null);
    AppStorage.set('isLogged', false);
    AppStorage.set('profilePixelMap', null);
    FileUtil.deleteFile(ProfileConstants.DISTRIBUTED_PROFILE_PATH);
    FileUtil.deleteFile(ProfileConstants.LOCAL_PROFILE_PATH);
    return this.preferenceManager.deleteValue(LOGIN_USER);
  }

  checkIsLogged(): Promise<boolean> {
    return this.preferenceManager.getValue<UserAccount>(LOGIN_USER).then((userAccount: UserAccount | null) => {
      if (userAccount) {
        AppStorage.setOrCreate('user', userAccount);
        AppStorage.setOrCreate('userId', userAccount.id);
        AppStorage.setOrCreate('isLogged', true);
        return true;
      }
      return false;
    });
  }

  saveDistributedUserData(userData: UserData): void {
    if (userData) {
      this.userDataForDis = userData;
      let userAccount: UserAccount = userData as UserAccount;
      this.collectedIds.length = 0;
      this.likedIds.length = 0;
      userData.collectedIds.forEach((item: string) => {
        this.collectedIds.push(item);
      })
      userData.likedIds.forEach((item: string) => {
        this.likedIds.push(item);
      })
      AppStorage.setOrCreate('user', userAccount);
      this.preferenceManager.setValue<UserAccount>(LOGIN_USER, userAccount);
    }
  }

  updateDataForDis() {
    this.userDataForDis.collectedIds = this.collectedIds;
    this.userDataForDis.likedIds = this.likedIds;
    ContinueModel.getInstance().data.userData = this.userDataForDis;
  }

  getUserData(): void {
    this.funNetwork.getUserData().then((data: UserData) => {
      this.collectedIds.length = 0;
      this.likedIds.length = 0;
      data.collectedIds.forEach((item: string) => {
        this.collectedIds.push(item);
      })
      data.likedIds.forEach((item: string) => {
        this.likedIds.push(item);
      })
      ContinueModel.getInstance().data.userData = data;
    })
  }

  getViewedResources(): Promise<void> {
    return new Promise((resolve: () => void, reject: () => void) => {
      this.funNetwork.getViewedResources().then((data: LearningResource[]) => {
        const viewedList: Array<LearningResource> = [];
        if (data) {
          data.forEach((res: LearningResource) => {
            viewedList.push(new LearningResource(res));
          });
          this.viewedDataSource.pushArrayData(viewedList);
        }
        resolve();
      }).catch((error: Error) => {
        this.showFailedToast();
        reject();
        Logger.error(TAG, `LoadMore Viewed failed! Error message is ${error}`);
      });
    });
  }

  getCollectedResources(): Promise<void> {
    return new Promise((resolve: () => void, reject: () => void) => {
      this.funNetwork.getCollectedResources().then((data: LearningResource[]) => {
        const collectedList: Array<LearningResource> = [];
        data.forEach((res: LearningResource) => {
          collectedList.push(new LearningResource(res));
        });
        this.collectedDataSource.pushArrayData(collectedList);
        Logger.info(TAG, `Load Collected Resources Success!`);
        resolve();
      }).catch((error: Error) => {
        this.showFailedToast();
        Logger.error(TAG, `Load Collected failed! Error message is ${error}`);
        reject();
      })
    });
  }

  getUserAchievements(): Promise<void> {
    return new Promise((resolve: () => void, reject: () => void) => {
      this.funNetwork.getAchievements().then((data: Achieve[]) => {
        this.learnedIds.length = 0;
        data.forEach((item: Achieve) => {
          if (item.isLearned) {
            this.learnedIds.push(item.pathId);
          }
        });
        Logger.info(TAG, 'Load Achievements Success!!' + JSON.stringify(this.learnedIds));
        resolve();
      }).catch((error: Error) => {
        this.showFailedToast()
        Logger.error(TAG, `LoadMore Achievements failed! Error message is ${error}`);
        reject();
      })
    });
  }

  handleCollected(resourceId: string): void {
    const index = this.collectedIds.findIndex((id: string) => id === resourceId);
    if (index === -1) {
      this.collectedIds.push(resourceId);
    } else {
      this.collectedIds.splice(index, 1);
    }
    this.funNetwork.toggleCollected(resourceId, index === -1 ? 1 : 0);
  }

  setCollectionCount(resourceId: string, isCollected: boolean): void {
    this.collectedDataSource.dataArray.forEach((res: LearningResource) => {
      if (res.id === resourceId) {
        res.isCollected = isCollected;
        res.collectionCount += isCollected ? 1 : -1;
      }
    });
    this.viewedDataSource.dataArray.forEach((res: LearningResource) => {
      if (res.id === resourceId) {
        res.isCollected = isCollected;
        res.collectionCount += isCollected ? 1 : -1;
      }
    });
  }

  handleCollectEvent(eventData: ActionEventData): void {
    const resourceId: string = eventData.resourceId;
    const actionValue: boolean = eventData.actionValue;
    this.handleCollected(resourceId);
    this.setCollectionCount(resourceId, actionValue);
    this.updateDataForDis();
  }

  handleLiked(resourceId: string): void {
    const index = this.likedIds.findIndex((id: string) => id === resourceId);
    if (index === -1) {
      this.likedIds.push(resourceId);
    } else {
      this.likedIds.splice(index, 1);
    }
    this.funNetwork.toggleLiked(resourceId, index === -1 ? 1 : 0);
  }

  setLikesCount(resourceId: string, isLiked: boolean): void {
    this.collectedDataSource.dataArray.forEach((res: LearningResource) => {
      if (res.id === resourceId) {
        res.isLiked = isLiked;
        res.likesCount += isLiked ? 1 : -1;
      }
    });
    this.viewedDataSource.dataArray.forEach((res: LearningResource) => {
      if (res.id === resourceId) {
        res.isLiked = isLiked;
        res.likesCount += isLiked ? 1 : -1;
      }
    })
  }

  handleLikeEvent(eventData: ActionEventData): void {
    const resourceId: string = eventData.resourceId;
    const actionValue: boolean = eventData.actionValue;
    this.handleLiked(resourceId);
    this.setLikesCount(resourceId, actionValue);
    this.updateDataForDis();
  }

  handleLearningEvent(learningId: string): void {
    this.learnedIds.push(learningId);
  }

  setViewsCount(resourceId: string): void {
    this.viewedDataSource.dataArray.forEach((res: LearningResource) => {
      if (res.id === resourceId) {
        res.viewsCount += 1;
      }
    });
    this.collectedDataSource.dataArray.forEach((res: LearningResource) => {
      if (res.id === resourceId) {
        res.viewsCount += 1;
      }
    });
  }

  savePushToken() {
    this.funNetwork.savePushToken();
  }
}

export enum TabInfo {
  COLLECTED = 0,
  VIEWED,
  ACHIEVEMENT
}
