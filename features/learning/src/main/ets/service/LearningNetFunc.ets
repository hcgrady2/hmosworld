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
import { Request } from '@ohos/network';
import { Logger, ResponseData } from '@ohos/utils';
import { LearningComment } from '../model/LearningComment';
import { LearningPath } from '../model/LearningPath';
import { LearningCommentsParams, LearningParams, UserIdParams } from './LearningParams';
import { LearningTrigger } from './LearningTrigger';

const TAG = '[LearningNetFunc]';

export class LearningNetFunc {
  public getLearningPaths(): Promise<LearningPath[]> {
    const params: UserIdParams = {
      userId: AppStorage.get<string>('userId') as string
    };
    return new Promise((resolve: (list: LearningPath[]) => void, reject: (error: BusinessError) => void) => {
      Request.call(LearningTrigger.LEARNING_PATHS, params)
        .then((result: Object) => {
          Logger.info(TAG, ' getLearningPaths success--------' + JSON.stringify(result));
          let pathList: LearningPath[] = [];
          if (result) {
            pathList = (result as LearningPath[]);
          }
          resolve(pathList);
        })
        .catch((error: BusinessError) => {
          Logger.error(TAG, 'getLearningPaths error--------' + JSON.stringify(error));
          reject(error);
        });
    });
  }

  public updateLearnedPath(pathId: string): Promise<void> {
    const params: LearningParams = {
      pathId,
      userId: AppStorage.get<string>('userId') as string
    };
    return new Promise((resolve: () => void, reject: (error: BusinessError) => void) => {
      Request.call(LearningTrigger.LEARNING_MODIFY, params).then(() => {
        Logger.info(TAG, ' updateLearnedPath success--------');
        resolve();
      }).catch((error: BusinessError) => {
        Logger.error(TAG, 'updateLearnedPath error--------' + JSON.stringify(error));
        reject(error);
      });
    });
  }

  public getLearningComments(pathId: string, pageNum: number): Promise<ResponseData<LearningComment>> {
    const param: LearningCommentsParams = {
      userId: AppStorage.get<string>('userId') as string,
      pathId,
      pageNum,
      pageSize: 20
    };
    return new Promise((resolve: (result: ResponseData<LearningComment>) => void, reject: (error: BusinessError) => void) => {
      Request.call(LearningTrigger.LEARNING_COMMENTS, param)
        .then((result: Object) => {
          Logger.info(TAG, 'getLearningComments success--------' + JSON.stringify(result));
          resolve(result as ResponseData<LearningComment>);
        }).catch((error: BusinessError) => {
        Logger.error(TAG, 'getLearningComments error--------' + JSON.stringify(error));
        reject(error);
      });
    });
  }
}