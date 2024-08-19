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

import { LearningResource } from '@ohos/mine';
import {
  BreakpointType,
  BreakpointTypeEnum,
  CommonConstants,
  ContinueModel,
  LazyDataSource,
  LoadingStatus,
  RouterNameEnum,
  TemplateEnum
} from '@ohos/utils';
import { LoadingMore, NoMore, TopNavigationView } from '@ohos/uicomponents';
import { DiscoverModel } from '../model/DiscoverModel';
import { FeedFlowItem } from '../components/FeedFlowItem';

@Component
export struct FeedWaterFlow {
  onDestinationBack: () => void = () => {
  };

  aboutToAppear(): void {
    ContinueModel.getInstance().setRouterName(RouterNameEnum.DISCOVER_FEED_WATER_FLOW);
  }

  aboutToDisappear(): void {
    ContinueModel.getInstance().resetContinue();
  }

  build() {
    NavDestination() {
      Column() {
        TopNavigationView({
          title: $r('app.string.hot_feeds'),
          onBackClick: () => this.onDestinationBack()
        })
        HotFeeds()
      }
      .padding({
        top: AppStorage.get<number>('statusBarHeight'),
      })
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.page_background_color'))
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
    }
    .height(CommonConstants.FULL_PERCENT)
    .width(CommonConstants.FULL_PERCENT)
    .onReady((cxt: NavDestinationContext) => {
      let params = cxt.pathInfo.param as Record<string, object>;
      this.onDestinationBack = params.onDestinationBack as () => boolean;
    })
    .hideTitleBar(true)
  }
}

@Component
struct HotFeeds {
  @Consume('discoverPathStack') discoverPathStack: NavPathStack;
  @Consume('appPathStack') appPathStack: NavPathStack;
  @State discoverModel: DiscoverModel = DiscoverModel.getInstance();
  @State hotFeedDataSource: LazyDataSource<LearningResource> = this.discoverModel.feedArticleDataSource;
  @State isListReachEnd: boolean = false;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  private cacheCount: number = 4;

  aboutToAppear(): void {
    this.cacheCount = new BreakpointType({
      sm: TemplateEnum.SM,
      md: TemplateEnum.MD,
      lg: TemplateEnum.LG
    }).getValue(this.currentBreakpoint);
  }

  @Builder
  WaterFlowFooter() {
    Column() {
      if (this.discoverModel.loadingFeedStatus === LoadingStatus.LOADING) {
        LoadingMore()
      }

      if (!this.discoverModel.hasNextFeed) {
        NoMore()
      }
    }
  }

  jumpDetail(item: LearningResource): void {
    if (this.currentBreakpoint === BreakpointTypeEnum.LG) {
      this.discoverPathStack.pushPathByName('DiscoverArticleDetail',
        new Object({
          articleDetail: item, onDestinationBack: () => {
            this.discoverPathStack.pop();
            return false;
          }
        }));
    } else {
      this.appPathStack.pushPathByName('DiscoverArticleDetail',
        new Object({
          articleDetail: item, onDestinationBack: () => {
            this.appPathStack.pop();
            return false;
          }
        }));
    }
  }

  build() {
    Column() {
      WaterFlow({ footer: this.WaterFlowFooter() }) {
        LazyForEach(this.hotFeedDataSource, (item: LearningResource, index: number) => {
          FlowItem() {
            FeedFlowItem({ feedItem: item })
              .reuseId('feedFlowItem')
          }
          .onClick(() => this.jumpDetail(item))
          .onAppear(() => {
            // Prematurely increasing data when bottoming is about to occur.
            if ((index + this.cacheCount) === this.hotFeedDataSource.totalCount()) {
              this.discoverModel.loadMoreFeed();
            }
          })
          .width(CommonConstants.FULL_PERCENT)
        }, (item: LearningResource) => item.id)
      }
      .cachedCount(this.cacheCount)
      .columnsTemplate(new BreakpointType({
        sm: '1fr 1fr',
        md: '1fr 1fr 1fr',
        lg: '1fr 1fr 1fr 1fr 1fr 1fr'
      }).getValue(this.currentBreakpoint))
      .itemConstraintSize({
        minWidth: 0,
        maxWidth: CommonConstants.FULL_PERCENT,
        minHeight: 0,
        maxHeight: CommonConstants.FULL_PERCENT
      })
      .columnsGap($r('app.float.md_padding_margin'))
      .rowsGap($r('app.float.md_padding_margin'))
      .padding({
        left: $r('app.float.md_padding_margin'),
        right: $r('app.float.md_padding_margin')
      })
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
    }
    .width(CommonConstants.FULL_PERCENT)
    .layoutWeight(1)
  }
}

@Builder
export function FeedWaterFlowBuilder() {
  FeedWaterFlow()
}