/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { LazyDataSource, LoadingStatus, Logger, ObservedArray, ResponseData, WebUtil } from '@ohos/utils';
import { LearningNetFunc } from '../service/LearningNetFunc';
import { LearningPath } from './LearningPath';
import { LearningComment } from './LearningComment';

const TAG = '[LearningModel]';

@Observed
export class LearningModel {
  private funNetwork: LearningNetFunc;
  private static instance: LearningModel;
  isLoading: LoadingStatus = LoadingStatus.SUCCESS; // Is Loading.
  isUpdating: boolean = false; // Is updating data
  list: ObservedArray<LearningPath> = DEFAULT_PATHS; // Data source.
  learningMap?: Map<string, LearningPath>;
  hasNextPage: boolean = true;
  currentPage: number = 0;
  learningCommentsDataSource: LazyDataSource<LearningComment> = new LazyDataSource();

  constructor() {
    Logger.info(TAG, 'LearningModel constructor');
    this.funNetwork = new LearningNetFunc();
  }

  /**
   * Get learning model instance.
   *
   * @returns learning model instance.
   */
  public static getInstance(): LearningModel {
    if (!LearningModel.instance) {
      LearningModel.instance = new LearningModel();
    }
    return LearningModel.instance;
  }

  /**
   * init list data and load learning path from servers.
   */
  init(): void {
    this.loadLearningPathData();
  }

  /**
   * Load learning path from servers.
   */
  loadLearningPathData(): void {
    this.funNetwork.getLearningPaths().then((data: LearningPath[]) => {
      Logger.info(TAG, 'loadLearningPathData data ' + JSON.stringify(data));
      this.list.forEach((path: LearningPath) => {
        path.isLearned = !!((data.find((item) => item.id === path.id))?.isLearned);
      });
      Logger.info(TAG, 'loadLearningPathData this.learningPathList: ' + JSON.stringify(this.list));
    }).catch((error: Error) => {
      Logger.error(TAG, 'loadLearningPathData error ' + JSON.stringify(error));
      this.list = DEFAULT_PATHS;
    });
  }

  /**
   * Update learning path status.
   *
   * @param pathId
   * @returns void
   */
  updateLearnedPath(pathId: string): Promise<void> {
    return new Promise((resolve: () => void, reject: () => void) => {
      this.isUpdating = true;
      this.funNetwork.updateLearnedPath(pathId).then(() => {
        this.isUpdating = false;
        Logger.info(TAG, 'updateLearnedPath data success');
        this.list.forEach((item: LearningPath) => {
          if (item.id === pathId) {
            item.isLearned = true;
          }
        });
        resolve();
      }).catch((error: Error) => {
        Logger.error(TAG, 'updateLearnedPath error ' + JSON.stringify(error));
        this.isUpdating = false;
        reject();
      });
    })
  }

  /**
   * Get learning path map.
   *
   * @returns learningMap
   */
  getLearningMap(): Map<string, LearningPath> {
    if (!this.learningMap) {
      let map = new Map<string, LearningPath>();
      DEFAULT_PATHS.forEach((item: LearningPath) => {
        map.set(item.id, item);
      });
      this.learningMap = map;
    }
    return this.learningMap;
  }

  getLearningComments(pathId: string, isFirstLoad: boolean): Promise<void> {
    if (isFirstLoad) {
      this.currentPage = 0;
    }
    return new Promise((resolve, reject) => {
      this.funNetwork.getLearningComments(pathId, this.currentPage + 1)
        .then((result: ResponseData<LearningComment>) => {
          const learningCommentList: Array<LearningComment> = [];
          result.resourceList.forEach((res: LearningComment) => {
            learningCommentList.push(res);
          });
          if (isFirstLoad) {
            this.learningCommentsDataSource.pushArrayData(learningCommentList);
          } else {
            this.learningCommentsDataSource.appendArrayData(learningCommentList);
          }
          this.currentPage = result.currentPage;
          this.hasNextPage = result.hasNext;
          resolve();
        }).catch((err: Error) => {
        Logger.error(TAG, `getLearningComments failed! Error message is ${JSON.stringify(err)}`);
        reject();
      });
    });
  }
}


const DEFAULT_PATHS: LearningPath[] = [
  new LearningPath(
    'p001',
    'HarmonyOS介绍',
    WebUtil.WebUrls.LEARNING_P001,
    '初识HarmonyOS特性，开启HarmonyOS学习之旅。',
    $r('app.media.ic_achieve_1'),
    $r('app.media.ic_learning_1'),
    false
  ),
  new LearningPath(
    'p002',
    'DevEco Studio的使用',
    WebUtil.WebUrls.LEARNING_P002,
    '安装体验DevEco Studio，运行您的第一个HarmonyOS应用。',
    $r('app.media.ic_achieve_2'),
    $r('app.media.ic_learning_2'),
    false
  ),
  new LearningPath(
    'p003',
    'ArkTS语法介绍',
    WebUtil.WebUrls.LEARNING_P003,
    '掌握基于TS扩展的ArkTS语言，以接近自然语义快速开发应用。',
    $r('app.media.ic_achieve_3'),
    $r('app.media.ic_learning_3'),
    false
  ),
  new LearningPath(
    'p004',
    '应用程序框架基础',
    WebUtil.WebUrls.LEARNING_P004,
    '从应用入口开始，了解用户如何与应用交互，理解应用的生命周期。',
    $r('app.media.ic_achieve_4'),
    $r('app.media.ic_learning_4'),
    false
  ),
  new LearningPath(
    'p005',
    '从简单的页面开始',
    WebUtil.WebUrls.LEARNING_P005,
    '了解基础组件、常用容器，并学习如何构建列表、页签切换等常用场景。',
    $r('app.media.ic_achieve_5'),
    $r('app.media.ic_learning_5'),
    false
  ),
  new LearningPath(
    'p006',
    '构建更加丰富的页面',
    WebUtil.WebUrls.LEARNING_P006,
    '了解组件状态管理，并学习一些常用组件以构建更加丰富的页面。',
    $r('app.media.ic_achieve_6'),
    $r('app.media.ic_learning_6'),
    false
  ),
  new LearningPath(
    'p007',
    '从网络获取数据',
    WebUtil.WebUrls.LEARNING_P007,
    '了解如何使用HTTP从网络获取数据，构建一个从网络实时获取数据的应用。',
    $r('app.media.ic_achieve_7'),
    $r('app.media.ic_learning_7'),
    false
  ),
  new LearningPath(
    'p008',
    '保存应用数据',
    WebUtil.WebUrls.LEARNING_P008,
    '存储应用的一些常用配置，以便应用可以持久化的存储数据。',
    $r('app.media.ic_achieve_8'),
    $r('app.media.ic_learning_8'),
    false
  )
];