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

import { common, ConfigurationConstant } from '@kit.AbilityKit';
import {
  BreakpointType,
  BreakpointTypeEnum,
  CommonConstants,
  ContinueModel,
  EventTypeEnum,
  LazyDataSource,
  Logger,
  ResourcesType,
  WindowUtil
} from '@ohos/utils';
import { NoMore } from '@ohos/uicomponents';
import { ArticleCardView } from './ArticleCardView';
import { FeedCardView } from './FeedCardView';
import Constants from '../constants/Constants';
import { LearningResource } from '../model/LearningResource';

const eventHub: common.EventHub = (getContext() as common.UIAbilityContext).eventHub;

const TAG = '[ResourceListView]';
let continueModel = ContinueModel.getInstance();

@Component
export struct ResourceListView {
  @Provide('listPathStack') listPathStack: NavPathStack = new NavPathStack();
  @Consume('appPathStack') appPathStack: NavPathStack;
  @StorageProp('currentBreakpoint') @Watch('handleBreakpointChange') currentBreakpoint: string = BreakpointTypeEnum.MD;
  scrollerForScroll?: Scroller;
  scrollerForList?: Scroller;
  @State selectedId: string = '';
  @Link resDataSource: LazyDataSource<LearningResource>;

  aboutToAppear() {
    let routerName = continueModel.geRouterName();
    Logger.info(TAG, 'aboutToAppear routerName is:' + routerName);

    let learningResource: LearningResource = this.resDataSource.dataArray[0];
    if (this.currentBreakpoint === BreakpointTypeEnum.LG || continueModel.isContinue) {
      if (continueModel.isContinue && continueModel.data.itemData) {
        learningResource = continueModel.data.itemData as LearningResource;
      }
      this.jumpDetail(learningResource);
    }
    eventHub.on(EventTypeEnum.MINE_REFRESH, ()=>{
      if (this.resDataSource.dataArray.length>0) {
        this.jumpDetail(this.resDataSource.dataArray[0]);
        this.scrollerForList?.scrollEdge(Edge.Start);
      }
    });
  }

  // 处理pad全屏模式和悬浮模式切换时列表和详情页显示异常问题
  handleBreakpointChange() {
    if (this.currentBreakpoint !== BreakpointTypeEnum.LG  && this.listPathStack.size() > 0) {
      this.listPathStack.clear();
      this.selectedId = '';
    } else if (this.currentBreakpoint === BreakpointTypeEnum.LG) {
      let articleDetail: LearningResource = this.resDataSource.getData(0);
      if (this.appPathStack.size() > 0) {
        const params = this.appPathStack.getParamByName('DiscoverArticleDetail')[0] as Record<string, object>;
        articleDetail = params.articleDetail as LearningResource;
      }
      this.jumpDetail(articleDetail);
    }
  }

  jumpDetail(item: LearningResource) {
    if (this.currentBreakpoint === BreakpointTypeEnum.LG) {
      continueModel.data.itemData = item;
      if (this.selectedId) {
        if (this.selectedId === item.id) {
          return;
        }
        this.listPathStack.replacePathByName('MineArticleDetail', new Object({ articleDetail: item, isLarge: false }));
      } else {
        this.listPathStack.pushPathByName('MineArticleDetail', new Object({ articleDetail: item, isLarge: false }));
      }
    } else {
      WindowUtil.updateStatusBarColor(getContext(this),
        AppStorage.get('currentColorMode') === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
      this.appPathStack.pushPathByName('DiscoverArticleDetail',
        new Object({
          articleDetail: item,
          onDestinationBack: () => {
            WindowUtil.updateStatusBarColor(getContext(this), true);
            this.appPathStack.pop();
            return false;
          }
        }));
    }
    this.selectedId = item.id;
  }

  build() {
    Navigation(this.listPathStack) {
      List({ space: CommonConstants.SPACE_12, scroller: this.scrollerForList }) {
        LazyForEach(this.resDataSource, (content: LearningResource) => {
          ListItem() {
            if (content.type === ResourcesType.ARTICLE) {
              ArticleCardView({
                articleItem: content,
                isSelected: this.currentBreakpoint === BreakpointTypeEnum.LG && this.selectedId === content.id,
                onCollected: (articleItem: LearningResource) => {
                  eventHub.emit(EventTypeEnum.COLLECTED, {
                    resourceId: articleItem.id,
                    resourceType: articleItem.type,
                    actionValue: !articleItem.isCollected
                  })
                },
                onLiked: (articleItem: LearningResource) => {
                  eventHub.emit(EventTypeEnum.LIKED, {
                    resourceId: articleItem.id,
                    resourceType: articleItem.type,
                    actionValue: !articleItem.isLiked
                  })
                }
              })
                .reuseId('mineArticle')
            } else {
              FeedCardView({
                isSelected: this.currentBreakpoint === BreakpointTypeEnum.LG && this.selectedId == content.id,
                articleItem: content
              })
                .reuseId('mineFeed')
            }
          }
          .borderRadius($r('app.float.xxl_border_radius'))
          .margin({ right: $r('app.float.md_padding_margin') })
          .onClick(()=> this.jumpDetail(content))
        }, (item: LearningResource, index: number) => JSON.stringify(item) + index)
        ListItem() {
          NoMore()
        }
      }
      .cachedCount(3)
      .padding({
        left: new BreakpointType({
          sm: $r('app.float.md_padding_margin'),
          md: $r('app.float.xxl_padding_margin'),
          lg: $r('app.float.xxl_padding_margin')
        }).getValue(this.currentBreakpoint),
        right: new BreakpointType<Length>({
          sm: 0,
          md: $r('app.float.md_padding_margin'),
          lg: 0
        }).getValue(this.currentBreakpoint)
      })
      .lanes(new BreakpointType({ sm: 1, md: Constants.COUNT_TWO, lg: 1 }).getValue(this.currentBreakpoint))
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
    }
    .navBarWidth(CommonConstants.NAVI_BAR_WIDTH)
    .mode(this.currentBreakpoint === BreakpointTypeEnum.LG ? NavigationMode.Split : NavigationMode.Stack)
    .hideTitleBar(true)
  }
}