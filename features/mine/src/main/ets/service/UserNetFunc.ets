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

/**
 * Using AGC Functions to Obtain Network Data.
 */
import { BusinessError } from '@kit.BasicServicesKit';
import { AAID, pushService } from '@kit.PushKit';
import { Request } from '@ohos/network';
import { Logger } from '@ohos/utils';
import { Achieve } from '../model/Achieve';
import { LearningResource } from '../model/LearningResource';
import { UserData } from '../model/UserData';
import { PushTokenParams, ToggleActionParams, UserIdParams } from './UserParams';
import { UserTrigger } from './UserTrigger';

const TAG = '[UserNetFunc]';

export class UserNetFunc {
  /**
   * @param userId
   * @returns UserData
   */
  public getUserData(): Promise<UserData> {
    const params: UserIdParams = {
      userId: AppStorage.get<string>('userId') as string
    };

    return new Promise(((resolve: (value: UserData | PromiseLike<UserData>) => void,
      reject: (reason?: Object) => void) => {
      Request.call(UserTrigger.USER_DATA, params).then((userData: Object) => {
        Logger.info(TAG, 'getUserData success--------' + JSON.stringify(userData));
        resolve(userData as UserData);
      }).catch((error: BusinessError) => {
        Logger.error(TAG, 'getUserData error--------' + JSON.stringify(error));
        reject(error);
      });
    }));
  }

  /**
   * @param userId
   * @returns Achieve[]
   */
  public getAchievements(): Promise<Achieve[]> {
    const params: UserIdParams = {
      userId: AppStorage.get<string>('userId') as string
    };
    return new Promise(((resolve: (value: Achieve[] | PromiseLike<Achieve[]>) => void,
      reject: (reason?: Object) => void) => {
      Request.call(UserTrigger.ACHIEVE, params).then((achieves: Object) => {
        Logger.info(TAG, 'getUserAchievements success------' + JSON.stringify(achieves));
        resolve(achieves as Achieve[]);
      }).catch((error: BusinessError) => {
        Logger.error(TAG, 'getUserAchievements error-----' + JSON.stringify(error));
        reject(error);
      });
    }));
  }

  /**
   * @param userId
   * @returns LearningResource[]
   */
  public getCollectedResources(): Promise<LearningResource[]> {
    const params: UserIdParams = {
      userId: AppStorage.get<string>('userId') as string
    };
    return new Promise(((resolve: (value: LearningResource[] | PromiseLike<LearningResource[]>) => void,
      reject: (reason?: Object) => void) => {
      Request.call(UserTrigger.COLLECT, params).then((learnResources: Object) => {
        Logger.info(TAG, 'getCollectResource success--------' + JSON.stringify(learnResources));
        resolve(learnResources as LearningResource[]);
      }).catch((error: BusinessError) => {
        Logger.error(TAG, 'getCollectResource error--------' + JSON.stringify(error));
        reject(error);
      });
    }));
  }

  /**
   * @param userId
   * @returns LearningResource[]
   */
  public getViewedResources(): Promise<LearningResource[]> {
    const params: UserIdParams = {
      userId: AppStorage.get<string>('userId') as string
    };
    return new Promise(((resolve: (value: LearningResource[] | PromiseLike<LearningResource[]>) => void,
      reject: (reason?: Object) => void) => {
      Request.call(UserTrigger.HISTORY, params).then((learnResources: Object) => {
        Logger.info(TAG, ' getViewedResource success--------' + JSON.stringify(learnResources));
        resolve(learnResources as LearningResource[]);
      }).catch((error: BusinessError) => {
        Logger.error(TAG, 'getViewedResource error--------' + JSON.stringify(error));
        reject(error);
      });
    }));
  }

  /**
   *
   * @param resourceId
   * @param operation
   * @param userId
   * @returns
   */
  public toggleLiked(resourceId: string, operation: number): Promise<void> {
    return new Promise((resolve: (value: void | PromiseLike<void>) => void,
      reject: (reason?: Object) => void) => {
      const params: ToggleActionParams = {
        resourceId,
        operation,
        userId: AppStorage.get<string>('userId') as string
      };
      Request.call(UserTrigger.LIKE, params).then((result: Object) => {
        Logger.info(TAG, 'toggleLiked success--------' + JSON.stringify(result));
        resolve();
      }).catch((error: BusinessError) => {
        Logger.error(TAG, 'toggleLiked error--------' + JSON.stringify(error));
        reject(error);
      });
    });
  }

  /**
   * @param resourceId
   * @param operation
   * @param userId
   * @returns
   */
  public toggleCollected(resourceId: string, operation: number): Promise<void> {
    return new Promise((resolve: (value: void | PromiseLike<void>) => void,
      reject: (reason?: Object) => void) => {
      const params: ToggleActionParams = {
        resourceId,
        operation,
        userId: AppStorage.get<string>('userId') as string
      };
      Request.call(UserTrigger.COLLECT_MODIFY, params).then((result: Object) => {
        Logger.info(TAG, 'toggleCollected success--------' + JSON.stringify(result));
        resolve();
      }).catch((error: BusinessError) => {
        Logger.error(TAG, 'toggleCollected error--------' + JSON.stringify(error));
        reject(error);
      });
    });
  }

  public savePushToken(): Promise<void> {
    return new Promise(async (resolve: (value: void | PromiseLike<void>) => void,
      reject: (reason?: Object) => void) => {
      try {
        const aaid: string = await AAID.getAAID();
        const pushToken: string = await pushService.getToken();
        Logger.info(TAG, 'Get AAID successfully: %{public}s', aaid);
        const params: PushTokenParams = {
          deviceId: aaid,
          pushToken,
          userId: AppStorage.get<string>('userId') as string
        };
        Request.call(UserTrigger.PUSH_TOKEN, params).then((result: Object) => {
          Logger.info(TAG, 'pushToken success--------' + JSON.stringify(result));
          resolve();
        }).catch((error: BusinessError) => {
          Logger.error(TAG, 'pushToken error--------' + JSON.stringify(error));
          reject(error);
        });
      } catch (err) {
        let e: BusinessError = err as BusinessError;
        reject(err);
        Logger.error(TAG, 'Get AAID catch error: %{public}d %{public}s', e.code, e.message);
      }
    });
  }
}