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

import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { LearningResource } from '@ohos/mine';
import { BreakpointType, BreakpointTypeEnum, CommonConstants, Logger } from '@ohos/utils';
import { DiscoverModel, HotListItem } from '../model/DiscoverModel';
import { SearchBar, RECOMMEND_THEME } from '../components/SearchBar';
import { SearchHistory } from '../components/SearchHistory';

const TAG = '[SearchPage]';
const DISCOVER_ITEM_LINE_HEIGHT = 20;

@Component
export struct SearchView {
  @StorageProp('currentBreakpoint') currentBreakpoint: BreakpointTypeEnum = BreakpointTypeEnum.MD;
  @Consume('appPathStack') appPathStack: NavPathStack;
  @State discoverModel: DiscoverModel = DiscoverModel.getInstance();
  @State searchValue: string = '';

  aboutToAppear(): void {
    this.discoverModel.getSearchHistory();
  }

  handleSearch(item: string): void {
    this.searchValue = item;
    this.discoverModel.search(this.searchValue);
    this.appPathStack.pushPathByName('SearchResultView', new Object({ searchValue: item }));
  }

  jumpToDetail(item: HotListItem): void {
    this.appPathStack.pushPathByName('DiscoverArticleDetail',
      new Object({
        articleDetail: item,
        onDestinationBack: () => {
          this.appPathStack.pop();
          return false;
        }
      }));
  }

  // confirm dialog
  confirmDeleteHistory(): void {
    promptAction.showDialog({
      message: $r('app.string.confirm_delete_search_history'),
      buttons: [
        {
          text: $r('app.string.cancel'),
          color: $r('sys.color.ohos_id_color_text_secondary')
        },
        {
          text: $r('app.string.sure'),
          color: $r('sys.color.ohos_id_color_text_secondary')
        }
      ],
      isModal: true,
      alignment: DialogAlignment.Center
    }, (err: BusinessError, data: promptAction.ShowDialogSuccessResponse) => {
      if (err) {
        Logger.info(TAG, `Show Dialog failed.Cause: ${err.message}.`);
        return;
      }
      if (data.index === 1) {
        this.discoverModel.clearSearchHistory();
        Logger.info(TAG, 'Delete search history success.')
      }
    });
  }

  build() {
    NavDestination() {
      Column() {
        // search area
        SearchBar({
          enableKeyboardOnFocus: true,
          searchValue: this.searchValue,
          onSearch: (value) => this.handleSearch(value),
          onBack: () => {
            this.appPathStack.clear();
            return false;
          }
        })
          .margin({
            left: new BreakpointType<Length>({
              sm: $r('app.float.lg_padding_margin'),
              md: $r('app.float.xxl_padding_margin'),
              lg: $r('app.float.xxxl_padding_margin'),
            }).getValue(this.currentBreakpoint),
            right: new BreakpointType<Length>({
              sm: $r('app.float.lg_padding_margin'),
              md: $r('app.float.xxl_padding_margin'),
              lg: $r('app.float.xxxl_padding_margin'),
            }).getValue(this.currentBreakpoint)
          })

        List({ space: CommonConstants.SPACE_4 }) {
          if (this.discoverModel.searchHistory.length > 0) {
            ListItem() {
              SearchHistory({
                data: this.discoverModel.searchHistory,
                title: $r('app.string.search_history'),
                onClickIcon: () => this.confirmDeleteHistory(),
                onClickText: (item: string) => this.handleSearch(item)
              })
            }
            .padding({
              left: new BreakpointType<Length>({
                sm: $r('app.float.lg_padding_margin'),
                md: $r('app.float.xxl_padding_margin'),
                lg: $r('app.float.xxxl_padding_margin'),
              }).getValue(this.currentBreakpoint),
              right: new BreakpointType<Length>({
                sm: $r('app.float.lg_padding_margin'),
                md: $r('app.float.xxl_padding_margin'),
                lg: $r('app.float.xxxl_padding_margin'),
              }).getValue(this.currentBreakpoint)
            })
          }

          ListItem() {
            searchDiscover(this.currentBreakpoint, (text) => this.handleSearch(text))
          }
          .padding({
            left: new BreakpointType<Length>({
              sm: $r('app.float.lg_padding_margin'),
              md: $r('app.float.xxl_padding_margin'),
              lg: $r('app.float.xxxl_padding_margin'),
            }).getValue(this.currentBreakpoint),
            right: new BreakpointType<Length>({
              sm: $r('app.float.lg_padding_margin'),
              md: $r('app.float.xxl_padding_margin'),
              lg: $r('app.float.xxxl_padding_margin'),
            }).getValue(this.currentBreakpoint)
          })

          ListItem() {
            if (this.discoverModel.hotList.length > 0) {
              Column() {
                hotCard(this.discoverModel.hotList, this.currentBreakpoint, (item) => this.jumpToDetail(item))
              }
              .padding($r('app.float.lg_padding_margin'))
              .borderRadius($r('app.float.lg_border_radius'))
              .margin({
                left: new BreakpointType<Length>({
                  sm: $r('app.float.lg_padding_margin'),
                  md: $r('app.float.xxl_padding_margin'),
                  lg: $r('app.float.xxxl_padding_margin'),
                }).getValue(this.currentBreakpoint),
                right: new BreakpointType<Length>({
                  sm: $r('app.float.lg_padding_margin'),
                  md: $r('app.float.xxl_padding_margin'),
                  lg: $r('app.float.xxxl_padding_margin'),
                }).getValue(this.currentBreakpoint)
              })
              .backgroundColor($r('app.color.article_background_color'))
            }
          }
        }
        .width(CommonConstants.FULL_PERCENT)
        .layoutWeight(1)
        .scrollBar(BarState.Off)
        .margin({ bottom: $r('app.float.lg_padding_margin') })
      }
      .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
      .padding({ top: AppStorage.get<number>('statusBarHeight') })
      .height(CommonConstants.FULL_PERCENT)
      .width(CommonConstants.FULL_PERCENT)
    }
    .hideTitleBar(true)
    .onBackPressed(() => {
      this.appPathStack.clear();
      return true;
    })
  }
}

// search discover
@Builder
function searchDiscover(currentBreakpoint: BreakpointTypeEnum, onClickText: (text: string) => void) {
  Column() {
    Row() {
      Text($r('app.string.search_discovery'))
        .fontSize($r('app.float.default_font_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('sys.color.ohos_id_color_text_secondary'))
    }
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .height($r('app.float.search_group_height'))
    .width(CommonConstants.FULL_PERCENT)

    List() {
      ForEach(RECOMMEND_THEME, (item: string) => {
        ListItem() {
          Text(item)
            .fontSize($r('app.float.md_font_size'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .lineHeight(DISCOVER_ITEM_LINE_HEIGHT)
        }
        .margin({
          bottom: $r('app.float.md_padding_margin')
        })
        .onClick(() => onClickText(item))
      })
    }
    .lanes(new BreakpointType({
      sm: CommonConstants.MD_COLUMN_COUNT,
      md: CommonConstants.MD_COLUMN_COUNT,
      lg: CommonConstants.LG_COLUMN_COUNT
    }).getValue(currentBreakpoint))
    .scrollBar(BarState.Off)
  }
  .width(CommonConstants.FULL_PERCENT)
}

// hot card
@Builder
function hotCard(list: HotListItem[], currentBreakpoint: BreakpointTypeEnum, jump: (item: HotListItem) => void) {

  Text($r('app.string.hmos_world_hot_list'))
    .fontSize($r('app.float.xl_font_size'))
    .fontWeight(FontWeight.Medium)
    .lineHeight($r('app.float.xl_line_height'))
    .fontColor($r('sys.color.ohos_id_color_text_primary'))
    .width(CommonConstants.FULL_PERCENT)
    .margin({ bottom: $r('app.float.sm_padding_margin') })

  List({ space: currentBreakpoint === BreakpointTypeEnum.SM ? 0 : CommonConstants.SPACE_4 }) {
    ForEach(list.slice(0, new BreakpointType({
      sm: 6,
      md: 8,
      lg: 9
    }).getValue(currentBreakpoint)), (item: HotListItem) => {
      ListItem() {
        Row() {
          Text(item.rank.toString())
            .width($r('app.float.lg_font_size'))
            .fontSize($r('app.float.large_text_size'))
            .fontWeight(item.rank < 4 ? FontWeight.Bold : FontWeight.Normal)
            .fontColor(item.rank < 4 ? $r('sys.color.ohos_id_color_text_primary_activated') :
            $r('sys.color.ohos_id_color_tertiary'))
          Image(item.headerImageUrl)
            .margin({ left: $r('app.float.xs_padding_margin') })
            .borderRadius($r('app.float.xxs_border_radius'))
            .height($r('app.float.view_count_icon_width'))
            .width($r('app.float.article_hots_height'))
          Column() {
            Text(item.title)
              .maxLines(1)
              .fontSize($r('app.float.md_font_size'))
              .lineHeight($r('app.float.md_line_height'))
              .fontWeight(FontWeight.Normal)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
            Text(item.title)
              .margin({ top: $r('app.float.xxs_padding_margin') })
              .maxLines(1)
              .fontSize($r('app.float.sm_font_size'))
              .lineHeight($r('app.float.sm_line_height'))
              .fontWeight(FontWeight.Normal)
              .fontColor($r('sys.color.ohos_id_color_tertiary'))
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
          }
          .layoutWeight(1)
          .padding({
            left: $r('app.float.md_padding_margin'),
            right: currentBreakpoint === BreakpointTypeEnum.SM ? $r('app.float.lg_padding_margin') :
            $r('app.float.xxl_padding_margin')
          })
        }
        .onClick(() => jump(item))
        .height($r('app.float.hot_card_item_height'))
      }
      .padding({ right: $r('app.float.lg_padding_margin') })
    }, (item: LearningResource) => item.id)
  }
  .scrollBar(BarState.Off)
  .lanes(new BreakpointType({
    sm: CommonConstants.SM_COLUMN_COUNT,
    md: CommonConstants.MD_COLUMN_COUNT,
    lg: CommonConstants.LG_COLUMN_COUNT
  }).getValue(currentBreakpoint))
}

@Builder
export function SearchViewBuilder() {
  SearchView()
}