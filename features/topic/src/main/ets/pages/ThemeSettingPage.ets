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
import { promptAction, router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { PreferenceManager } from '@ohos/datastore';
import {
  BreakpointSystem,
  BreakpointType,
  BreakpointTypeEnum,
  LoadingStatus,
  Logger,
  ObservedArray,
  WindowUtil
} from '@ohos/utils';
import { LoadingFailedView, LoadingView } from '@ohos/uicomponents';
import { ThemeConstants } from '../constants/ThemeConstants';
import { TopicItemView } from '../components/TopicItemView';
import { TopicModel } from '../model/TopicModel';
import { Topic, TopicType } from '../model/Topic';

const context = (getContext(this) as common.UIAbilityContext);
const TAG = '[ThemeSettingPage]';

@Entry({ routeName: 'ThemeSettingPage' })
@Component
struct ThemeSettingPage {
  private preferenceManager: PreferenceManager = PreferenceManager.getInstance();
  @State topicModel: TopicModel = TopicModel.getInstance();
  @State firstTopic: boolean = !!((router.getParams()) as Record<string, boolean>)?.['firstTopic'];
  @State totalTopics: ObservedArray<Topic> = this.topicModel.totalTopicList;
  @State selectedTopics: ObservedArray<Topic> = [];
  @State loadingStatus: LoadingStatus = LoadingStatus.OFF;
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  private breakpointSystem: BreakpointSystem = new BreakpointSystem();
  @State saveTitle: ResourceStr = $r('app.string.complete');
  @State @Watch('savingEffect') saving: boolean = false;
  private intervalId: number = 0;

  aboutToAppear() {
    WindowUtil.updateStatusBarColor(getContext(this),
      AppStorage.get('currentColorMode') === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    this.loadTopics();
    this.breakpointSystem.register();
    WindowUtil.setMissionContinueActive(context, false);
  }

  loadTopics(): void {
    this.loadingStatus = LoadingStatus.LOADING;
    this.topicModel.getTopics().then(() => {
      this.selectedTopics = this.topicModel.totalTopicList.filter(topic => topic.isFollowed);
      this.loadingStatus = LoadingStatus.SUCCESS;
    }).catch((err: Error) => {
      this.loadingStatus = LoadingStatus.FAILED;
      Logger.error(TAG, `loading topics error: ${err}`);
    });
  }

  aboutToDisappear() {
    this.breakpointSystem.unregister();
    WindowUtil.setMissionContinueActive(context, true);
    WindowUtil.updateStatusBarColor(getContext(this), true);
  }

  handleClickTopicItem(item: Topic): void {
    const index = this.selectedTopics.findIndex(topic => topic.id === item.id && topic.type === item.type);
    if (index !== -1) {
      this.selectedTopics.splice(index, 1);
    } else {
      this.selectedTopics.push(new Topic(item));
    }
  }

  isButtonEnabled() {
    return this.selectedTopics.filter(topic => topic.type === TopicType.FEED).length !== 0
      && this.selectedTopics.filter(topic => topic.type === TopicType.TOPIC).length !== 0;
  }

  checkTopicChanged() {
    const initialSelectedTopics = this.totalTopics.filter(topic => topic.isFollowed);
    return !(this.selectedTopics.length === initialSelectedTopics.length
      &&
    this.selectedTopics.every(selectedTopic => initialSelectedTopics.find(topic => topic.id === selectedTopic.id)));
  }

  @Builder
  TitleBuilder() {
    Row() {
      if (!this.firstTopic) {
        Image($r('app.media.ic_back'))
          .size({
            width: $r('app.float.topic_back_size'),
            height: $r('app.float.topic_back_size')
          })
          .onClick(() => {
            router.back();
          })
      }
      Column() {
        Text($r('app.string.preference_title'))
          .fontFamily($r('app.string.topic_title_main_family'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('sys.color.ohos_id_color_foreground'))
          .fontSize($r('app.float.topic_main_font'))
        Text($r('app.string.preference_subtitle'))
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width(ThemeConstants.FULL_SIZE)
          .fontFamily($r('app.string.topic_title_family'))
          .fontColor($r('sys.color.ohos_id_color_focused_content_second'))
          .fontSize($r('app.float.topic_sub_font'))
          .margin({ top: $r('app.float.topic_title_margin') })
      }
      .layoutWeight(1)
      .padding({ left: this.firstTopic ? 0 : $r('app.float.topic_title_padding') })
      .height($r('app.float.topic_navigation_height'))
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Start)
    }
    .width(ThemeConstants.FULL_SIZE)
    .padding({
      left: $r('app.float.xxl_padding_margin'),
      right: $r('app.float.xxl_padding_margin'),
      top: AppStorage.get<number>('statusBarHeight')
    })
  }

  @Builder
  TopicTypeBuilder(type: TopicType) {
    Row() {
      Text(type === TopicType.FEED ? $r('app.string.feed') : $r('app.string.topic'))
        .fontFamily($r('app.string.topic_title_main_family'))
        .fontWeight(FontWeight.Medium)
        .fontSize($r('app.float.topic_type_font'))
        .fontColor($r('sys.color.ohos_id_color_foreground'))
    }
    .width(ThemeConstants.FULL_SIZE)
    .height($r('app.float.topic_back_size'))
    .margin({ top: $r('app.float.xxl_padding_margin'), bottom: $r('app.float.lg_padding_margin') })
  }

  savingEffect(): void {
    let count = 1;
    const loadingList = ['  ', '. ', '..'];
    if (this.saving) {
      this.saveTitle = $r('app.string.saving',loadingList[0]);
      this.intervalId = setInterval(() => {
        count++;
        count %= 3;
        this.saveTitle = $r('app.string.saving', loadingList[count]);
      }, 500);
    } else {
      clearTimeout(this.intervalId);
      this.saveTitle = $r('app.string.complete');
    }
  }

  jump(): void {
    if (this.firstTopic) {
      this.preferenceManager.setValue('ThemeIsSet', true);
    }
    const bundleName = (getContext(this) as common.UIAbilityContext).applicationInfo.name;
    const url = `@bundle:${bundleName}/phone/ets/pages/MainPage`;
    // Check whether the topic is modified.If yes, send a network request. Otherwise, return to the previous page.
    // If the interface is successfully invoked, the new resource list is obtained and routed to the exploration page.
    // Otherwise, the route is not redirected and prompt failure information.
    const shouldUpdate = this.checkTopicChanged();
    if (shouldUpdate) {
      this.saving = true;
      this.topicModel.updateFollowedTopics(this.selectedTopics.map(topic => topic.id)).then(() => {
        promptAction.showToast({
          message: $r('app.string.topic_update_success')
        });
        this.saving = false;
        AppStorage.setOrCreate('getHomeResource', true);
        if (this.firstTopic) {
          router.replaceUrl({ url });
        } else {
          router.back();
        }
      }).catch((err: BusinessError) => {
        promptAction.showToast({
          message: $r('app.string.topic_update_fail')
        });
        this.saving = false;
        Logger.error(TAG, `save error: ${err}`);
      })
    } else {
      if (this.firstTopic) {
        router.replaceUrl({ url });
      } else {
        router.back();
      }
    }
  }

  build() {
    Stack() {
      Image($r('app.media.ic_bg_theme'))
        .objectFit(ImageFit.Fill)
        .width(ThemeConstants.FULL_SIZE)
        .height(ThemeConstants.FULL_SIZE)
      Scroll() {
        Column() {
          this.TitleBuilder()
          if (this.loadingStatus === LoadingStatus.LOADING) {
            LoadingView();
          }
          if (this.loadingStatus === LoadingStatus.FAILED) {
            LoadingFailedView(() => this.loadTopics())
          }
          if (this.loadingStatus === LoadingStatus.SUCCESS) {
            Column() {
              ForEach([TopicType.FEED, TopicType.TOPIC], (type: TopicType) => {
                this.TopicTypeBuilder(type)
                GridRow({
                  columns: {
                    xs: ThemeConstants.COLUMNS_SM,
                    sm: ThemeConstants.COLUMNS_SM,
                    md: ThemeConstants.COLUMNS_MD,
                    lg: ThemeConstants.COLUMNS_LG
                  },
                  gutter: {
                    x: {
                      xs: ThemeConstants.GUTTER_12,
                      sm: ThemeConstants.GUTTER_12,
                      md: ThemeConstants.GUTTER_40,
                      lg: ThemeConstants.GUTTER_40
                    },
                    y: {
                      xs: ThemeConstants.GUTTER_30,
                      sm: ThemeConstants.GUTTER_30,
                      md: ThemeConstants.GUTTER_40,
                      lg: ThemeConstants.GUTTER_40
                    }
                  }
                }) {
                  ForEach(this.totalTopics.filter(topic => topic.type === type), (item: Topic) => {
                    GridCol() {
                      TopicItemView({
                        item,
                        handleClick: () => this.handleClickTopicItem(item)
                      })
                    }
                  }, (item: Topic) => item.id)
                }
                .padding({
                  left: new BreakpointType<Length>({
                    sm: 0,
                    md: $r('app.float.lg_padding_margin'),
                    lg: $r('app.float.xl_padding_margin')
                  }).getValue(this.currentBreakpoint),
                  right: new BreakpointType<Length>({
                    sm: 0,
                    md: $r('app.float.lg_padding_margin'),
                    lg: $r('app.float.xl_padding_margin')
                  }).getValue(this.currentBreakpoint),
                  bottom: $r('app.float.xxl_padding_margin')
                })
              }, (item: number) => item.toString())
            }
            .margin({
              left: new BreakpointType<Length>({
                sm: $r('app.float.xxl_padding_margin'),
                md: $r('app.float.xxl_padding_margin'),
                lg: ThemeConstants.PERCENT_13
              }).getValue(this.currentBreakpoint),
              right: new BreakpointType<Length>({
                sm: $r('app.float.xxl_padding_margin'),
                md: $r('app.float.xxl_padding_margin'),
                lg: ThemeConstants.PERCENT_13
              }).getValue(this.currentBreakpoint)
            })

            Blank()
            Button(this.saveTitle, {
              type: ButtonType.Capsule,
              stateEffect: this.isButtonEnabled()
            })
              .width(new BreakpointType({
                sm: ThemeConstants.HALF_PERCENT,
                md: ThemeConstants.BUTTON_LG,
                lg: ThemeConstants.BUTTON_LG
              }).getValue(this.currentBreakpoint))
              .height($r('app.float.ListItemGroup_padding'))
              .backgroundColor($r('sys.color.ohos_id_color_component_activated'))
              .borderRadius(ThemeConstants.HALF_PERCENT)
              .enabled(this.isButtonEnabled())
              .onClick(() => this.jump())
              .margin($r('app.float.topic_back_size'))
          }
        }
      }
      .scrollBar(BarState.Off)
      .width(ThemeConstants.FULL_SIZE)
      .height(ThemeConstants.FULL_SIZE)
      Column()
        .visibility(this.saving ? Visibility.Visible : Visibility.None)
        .backgroundColor(Color.Transparent)
        .width(ThemeConstants.FULL_SIZE)
        .height(ThemeConstants.FULL_SIZE)
    }
  }
}