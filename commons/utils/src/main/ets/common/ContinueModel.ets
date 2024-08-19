/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

export class CData {
  mainTabIndex: number = 0;
  mineTabIndex: number = 0;
  routerName: RouterNameEnum = RouterNameEnum.UNKNOWN;
  itemData: Object= new Object();
  userData: Object = new Object();
}

export class ContinueModel {
  public data: CData;
  public isContinue: boolean = false;
  private static instance: ContinueModel;

  public static getInstance(): ContinueModel {
    if (!ContinueModel.instance) {
      ContinueModel.instance = new ContinueModel();
    }
    return ContinueModel.instance;
  }

  public constructor() {
    this.data = new CData();
  }

  public resetContinue() {
    this.data.routerName = RouterNameEnum.UNKNOWN;
    this.isContinue = false;
  }

  public setRouterName(routerName: RouterNameEnum) {
    this.data.routerName = routerName;
  }

  public geRouterName(): string {
    return this.data?.routerName;
  }

  public setData(routerName: RouterNameEnum, itemData: object) {
    this.data.routerName = routerName;
    this.data.itemData = itemData;
  }
}

export enum RouterNameEnum {

  //discover
  DISCOVER_ARTICLE_VIEW = '@ohos/discover_ArticleDetailView',
  DISCOVER_FEED_WATER_FLOW = '@ohos/discover_FeedWaterFlow',
  DISCOVER_SEARCH = '@ohos/discover_Search',
  DISCOVER_SEARCH_RESULT = '@ohos/discover_SearchResult',
  //learn
  LEARNING_DETAIL = '@ohos/learning_LearningDetailPage',

  // challenge
  CHALLENGE_DETAIL = '@ohos/challenge_ChallengeDetailPage',

  //mine
  MINE_ARTICLE_VIEW = '@ohos/mine_ArticleDetailView',
  MINE_PHOTO = '@ohos/mine_PhotoPage',
  MINE_PHOTO_CONFIRM = '@ohos/mine_ConfirmPage',
  MINE_SETTING = '@ohos/mine_SettingView',
  MINE_ACCOUNT ='@ohos/mine_UserAccountView',
  MINE_THEME_CONFIG = '@ohos/mine_ThemeConfigView',

  UNKNOWN = '',
}