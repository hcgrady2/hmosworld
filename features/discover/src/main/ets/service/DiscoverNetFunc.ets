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
import { LearningResource } from '@ohos/mine';
import { Request } from '@ohos/network';
import { Logger, ResourcesType, ResponseData } from '@ohos/utils';
import { HomeResources } from '../model/HomeResource';
import { GetMoreResourcesParams, SearchParams, UserIdParams } from './DiscoverParams';
import { DiscoverTrigger } from './DiscoverTrigger';

const TAG = '[DiscoverNetFunc]';
const RESOURCE_PAGE_SIZE = 10;

export class DiscoverNetFunc {
  /**
   * @returns NetworkNewsResources
   */
  public getHomeResources(): Promise<HomeResources> {
    const params: UserIdParams = {
      userId: AppStorage.get<string>('userId') as string
    };

    return new Promise((resolve: (value: HomeResources | PromiseLike<HomeResources>) => void,
                        reject: (reason?: Object) => void) => {
      Request.call(DiscoverTrigger.HOME_RESOURCE, params).then((result: Object) => {
        Logger.info(TAG, 'getHomeResources success--------' + JSON.stringify(result));
        resolve(result as HomeResources);
      }).catch((error: BusinessError) => {
        Logger.error(TAG, 'getHomeResources error--------' + JSON.stringify(error));
        reject(error);
      });
    });
  }

  /**
   * @param pageNum
   * @param type
   * @returns ResourcesData
   */
  public getMoreResources(pageNum: number, type: ResourcesType): Promise<ResponseData<LearningResource>> {
    const params: GetMoreResourcesParams = {
      userId: AppStorage.get<string>('userId') as string,
      type,
      pageNum,
      pageSize: RESOURCE_PAGE_SIZE
    };

    return new Promise((resolve: (value: ResponseData<LearningResource> | PromiseLike<ResponseData<LearningResource>>) => void,
                        reject: (reason?: Object) => void) => {
      Request.call(DiscoverTrigger.RESOURCE_PAGE, params).then((resourcesData: Object) => {
        Logger.info(TAG, 'getMoreResources success--------' + JSON.stringify(resourcesData));
        resolve(resourcesData as ResponseData<LearningResource>);
      }).catch((error: BusinessError) => {
        Logger.error(TAG, 'getMoreResources error--------' + JSON.stringify(error));
        reject(error);
      });
    });
  }

  /**
   * @returns LearningResource[]
   */
  public getHotList(): Promise<LearningResource[]> {
    return new Promise((resolve: (value: LearningResource[] | PromiseLike<LearningResource[]>) => void,
                        reject: (reason?: Object) => void) => {
      Request.call(DiscoverTrigger.RESOURCE_HOT).then((resourcesData: Object) => {
        Logger.info(TAG, 'get hot list success--------' + JSON.stringify(resourcesData));
        resolve(resourcesData as LearningResource[]);
      }).catch((error: BusinessError) => {
        Logger.error(TAG, 'get hot list error--------' + JSON.stringify(error));
        reject(error);
      });
    });
  }

  /**
   * @param SearchParams
   * @returns LearningResource[]
   */
  public search(params: SearchParams): Promise<LearningResource[]> {
    return new Promise((resolve: (value: LearningResource[] | PromiseLike<LearningResource[]>) => void,
                        reject: (reason?: Object) => void) => {
      Request.call(DiscoverTrigger.RESOURCE_SEARCH, params).then((resourcesData: Object) => {
        Logger.info(TAG, 'search success--------' + JSON.stringify(resourcesData));
        resolve(resourcesData as LearningResource[]);
      }).catch((error: BusinessError) => {
        Logger.error(TAG, 'search error--------' + JSON.stringify(error));
        reject(error);
      });
    });
  }
}