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
import { BusinessError } from '@kit.BasicServicesKit';
import { PreferenceManager } from '@ohos/datastore';
import { ActionEventData, LearningResource } from '@ohos/mine';
import { EventTypeEnum, LazyDataSource, LoadingStatus, Logger, ResourcesType, ResponseData } from '@ohos/utils';
import { DiscoverNetFunc } from '../service/DiscoverNetFunc';
import { HomeResources } from './HomeResource';

const TAG = '[DiscoverModel]';
const MAX_HISTORY_COUNT = 10;

export class HotListItem extends LearningResource {
  rank: number = 0;
}

@Observed
export class DiscoverModel {
  private funNetwork: DiscoverNetFunc;
  // Home page data loaded for the first time
  loadingStatus: LoadingStatus = LoadingStatus.OFF;
  swiperData: LearningResource[] = [];
  // Load more articles
  loadingArticleStatus: LoadingStatus = LoadingStatus.OFF;
  hasNextArticle: boolean = true;
  curArticlePage: number = 0;
  // Load more feeds
  loadingFeedStatus: LoadingStatus = LoadingStatus.OFF;
  hasNextFeed: boolean = true;
  curFeedPage: number = 0;
  // Load detail
  detailLoadingStatus: LoadingStatus = LoadingStatus.OFF;
  // Load search page
  searchLoadingStatus: LoadingStatus = LoadingStatus.OFF;
  hotList: HotListItem[] = [];
  searchHistory: string[] = [];
  private static instance: DiscoverModel;
  private preferenceManager: PreferenceManager = PreferenceManager.getInstance();
  feedArticleDataSource: LazyDataSource<LearningResource> = new LazyDataSource();
  techArticleDataSource: LazyDataSource<LearningResource> = new LazyDataSource();
  searchResultDataSource: LazyDataSource<LearningResource> = new LazyDataSource();

  private constructor() {
    Logger.info(TAG, 'DiscoverModel constructor');
    this.funNetwork = new DiscoverNetFunc();
    // Subscribing to public events
    const eventHub: common.EventHub = (getContext(this) as common.UIAbilityContext).eventHub;
    eventHub.on(EventTypeEnum.COLLECTED,
      (eventData: ActionEventData): void => this.setCollectionCount(eventData));
    eventHub.on(EventTypeEnum.LIKED, (eventData: ActionEventData): void => this.setLikesCount(eventData));
  }

  /**
   * Get discover model instance.
   *
   * @returns discover model instance.
   */
  public static getInstance(): DiscoverModel {
    if (!DiscoverModel.instance) {
      DiscoverModel.instance = new DiscoverModel();
    }
    return DiscoverModel.instance;
  }

  /**
   * Data loaded on the home page converts network data into page rendering data
   */
  getHomeResources(): Promise<void> {
    this.loadingStatus = LoadingStatus.LOADING;
    return new Promise((resolve, reject) => {
      this.funNetwork.getHomeResources().then((data: HomeResources) => {
        const feedArticleList: Array<LearningResource> = [];
        data.feedData.resourceList.forEach((res: LearningResource) => {
          feedArticleList.push(new LearningResource(res));
        });
        this.feedArticleDataSource.pushArrayData(feedArticleList);

        const techArticleList: Array<LearningResource> = [];
        data.articleData.resourceList.forEach((res: LearningResource) => {
          techArticleList.push(new LearningResource(res));
        });
        this.techArticleDataSource.pushArrayData(techArticleList);

        this.swiperData.length = 0;
        this.swiperData = data.bannerList;
        // load more info
        this.curArticlePage = data.articleData.currentPage;
        this.hasNextArticle = data.articleData.hasNext;
        this.curFeedPage = data.feedData.currentPage;
        this.hasNextFeed = data.feedData.hasNext;
        // loading status
        this.loadingStatus = LoadingStatus.SUCCESS;
        Logger.info(TAG, JSON.stringify(this.swiperData));
        resolve();
      }).catch((err: Error) => {
        this.loadingStatus = LoadingStatus.FAILED;
        Logger.error(TAG, `Init failed! Error message is ${err}`);
        reject();
      });
    });
  }

  /**
   * Load next page article data
   */
  loadMoreArticle(): Promise<LearningResource[]> {
    this.loadingArticleStatus = LoadingStatus.LOADING;
    return new Promise((resolve, reject) => {
      this.funNetwork.getMoreResources(this.curArticlePage + 1, ResourcesType.ARTICLE)
        .then((data: ResponseData<LearningResource>) => {
          const techArticleList: Array<LearningResource> = [];
          data.resourceList.forEach((res: LearningResource) => {
            techArticleList.push(new LearningResource(res));
          });
          this.techArticleDataSource.appendArrayData(techArticleList);
          this.curArticlePage = data.currentPage;
          this.hasNextArticle = data.hasNext;
          this.loadingArticleStatus = LoadingStatus.SUCCESS;
          Logger.info(TAG, 'LoadMore articles success!');
          resolve(data.resourceList);
        })
        .catch((err: Error) => {
          this.loadingArticleStatus = LoadingStatus.FAILED;
          promptAction.showToast({
            message: $r('app.string.load_failed')
          });
          reject();
          Logger.error(TAG, `LoadMore articles failed! Error message is ${err}.`);
        });
    })
  }

  /**
   * Load next page feed data
   */
  loadMoreFeed(): void {
    if (this.hasNextFeed) {
      this.loadingFeedStatus = LoadingStatus.LOADING;
      this.funNetwork.getMoreResources(this.curFeedPage + 1, ResourcesType.FEED)
        .then((data: ResponseData<LearningResource>) => {
          const feedArticleList: Array<LearningResource> = [];
          data.resourceList.forEach((res: LearningResource) => {
            feedArticleList.push(new LearningResource(res));
          });
          this.feedArticleDataSource.appendArrayData(feedArticleList);

          this.curFeedPage = data.currentPage;
          this.hasNextFeed = data.hasNext;
          this.loadingFeedStatus = LoadingStatus.SUCCESS;
          Logger.info(TAG, 'LoadMore feed success!' + JSON.stringify(data));
        })
        .catch((err: Error) => {
          this.loadingFeedStatus = LoadingStatus.FAILED;
          promptAction.showToast({
            message: $r('app.string.load_failed')
          });
          Logger.error(TAG, `LoadMore feed failed! Error message is ${err}.`);
        });
    }
  }

  /**
   * Set view counts of feed or article by resourceId
   * @param resourceId
   */
  setViewsCount(resourceId: string): void {
    this.feedArticleDataSource.dataArray.forEach((res: LearningResource) => {
      if (res.id === resourceId) {
        res.viewsCount += 1;
      }
    });
    this.techArticleDataSource.dataArray.forEach((res: LearningResource) => {
      if (res.id === resourceId) {
        res.viewsCount += 1;
      }
    });
  }

  /**
   * Set collection count of feed or article through public event parameters
   * @param eventData
   */
  setCollectionCount(eventData: ActionEventData): void {
    if (eventData.resourceType === ResourcesType.FEED) {
      this.feedArticleDataSource.dataArray.forEach((res: LearningResource) => {
        if (res.id === eventData.resourceId) {
          res.collectionCount += eventData.actionValue ? 1 : -1;
          return;
        }
      });
    } else if (eventData.resourceType === ResourcesType.ARTICLE) {
      this.techArticleDataSource.dataArray.forEach((res: LearningResource) => {
        if (res.id === eventData.resourceId) {
          res.collectionCount += eventData.actionValue ? 1 : -1;
          return;
        }
      });
    }
  }

  /**
   * Set likes count of feed or article through public event parameters
   * @param eventData
   */
  setLikesCount(eventData: ActionEventData): void {
    if (eventData.resourceType === ResourcesType.FEED) {
      this.feedArticleDataSource.dataArray.forEach((res: LearningResource) => {
        if (res.id === eventData.resourceId) {
          res.likesCount += eventData.actionValue ? 1 : -1;
        }
      });
    }
    if (eventData.resourceType === ResourcesType.ARTICLE) {
      this.techArticleDataSource.dataArray.forEach((res: LearningResource) => {
        if (res.id === eventData.resourceId) {
          res.likesCount += eventData.actionValue ? 1 : -1;
        }
      });
    }
  }

  /**
   * Load hot list data on search page
   */
  getHotList(): void {
    this.funNetwork.getHotList()
      .then((data: LearningResource[]) => {
        this.hotList.length = 0;
        this.hotList = data.map((item: LearningResource, index: number) => {
          (item as HotListItem).rank = index + 1;
          return item as HotListItem;
        });
        Logger.info(TAG, 'Get hot list success!', JSON.stringify(data));
      })
      .catch((err: Error) => {
        promptAction.showToast({
          message: $r('app.string.load_failed')
        });
        Logger.error(TAG, `Get hot list failed! Error message is ${err}.`);
      });
  }

  /**
   * search resource by  keywords on search page
   */
  search(value: string): void {
    // Update search history.
    if (!this.searchHistory.includes(value)) {
      // Add the current search content to the top of the search history.
      this.searchHistory.unshift(value);
    } else {
      // Move an existing search to the top of the search history.
      this.searchHistory.map((historyItem, index) => {
        if (historyItem === value) {
          this.searchHistory.unshift(this.searchHistory.splice(index, 1)[0]);
        }
      })
    }
    // The number of historical search records cannot exceed MAX_HISTORY_COUNT.
    if (this.searchHistory.length > MAX_HISTORY_COUNT) {
      this.searchHistory.pop();
    }

    this.preferenceManager.setValue<string[]>('searchHistory', this.searchHistory);
    // Call network search api.
    this.searchLoadingStatus = LoadingStatus.LOADING;
    this.funNetwork.search({ keyWords: value })
      .then((data: LearningResource[]) => {
        const result: Array<LearningResource> = [];
        data.forEach((res: LearningResource) => {
          result.push(new LearningResource(res));
        });
        this.searchResultDataSource.clear();
        this.searchResultDataSource.appendArrayData(result);
        this.searchLoadingStatus = LoadingStatus.SUCCESS;
        Logger.info(TAG, 'search success!');
      })
      .catch((err: Error) => {
        this.searchLoadingStatus = LoadingStatus.FAILED;
        promptAction.showToast({
          message: $r('app.string.load_failed')
        });
        Logger.error(TAG, `search failed! Error message is ${err}.`);
      });
  }

  /**
   * get search history
   */
  getSearchHistory(): void {
    this.preferenceManager.getValue<string[]>('searchHistory').then(res => {
      this.searchHistory = res ?? [];
      Logger.error(TAG, 'Get search History success.');
    }).catch((err: BusinessError) => Logger.error(TAG, 'Get search History Failed. Cause: ' + err));
  }

  /**
   * clear search history
   */
  clearSearchHistory(): void {
    this.preferenceManager.deleteValue('searchHistory').then(res => {
      this.searchHistory = [];
      Logger.error(TAG, 'Delete search History success.' + JSON.stringify(res));
    }).catch((err: BusinessError) => Logger.error(TAG, 'Delete search History Failed. Cause: ' + err));
  }
}