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

import { LoadingView, NoMore } from '@ohos/uicomponents';
import {
  ColumnEnum,
  CommonConstants,
  ContinueModel,
  LazyDataSource,
  Logger,
  OffsetEnum,
  RouterNameEnum,
  SpanEnum,
  WebUtil
} from '@ohos/utils';
import { CommentItem } from '../components/CommentItem';
import { LearningConstants } from '../constants/LearningConstants';
import { LearningPath } from '../model/LearningPath';
import { LearningModel } from '../model/LearningModel';
import { LearningComment } from '../model/LearningComment';

const TAG = '[LearningDetailPage]';

const LEARN_MIN_DURATION = 5;
let continueModel = ContinueModel.getInstance();

@Component
export struct LearningDetailView {
  @State learningModel: LearningModel = LearningModel.getInstance();
  @State commentList: Array<LearningComment> = [];
  @State learningItem: LearningPath = new LearningPath();
  onDestinationBack: (learningId?: string) => void = () => {
  };
  @StorageProp('foldExpanded') foldExpanded: boolean = false;
  @State showComment: boolean = false;
  @State showCommentBtn: boolean = false;
  @State loadingCommentsStatus: boolean = false;
  private intervalId?: number;
  private learnSeconds: number = 0;
  @State learningCommentsDataSource: LazyDataSource<LearningComment> = this.learningModel.learningCommentsDataSource;

  aboutToDisappear(): void {
    ContinueModel.getInstance().resetContinue();
  }

  onBackPressBack() {
    let webController = WebUtil.getController(this.learningItem.url);
    if (webController?.accessBackward()) {
      webController?.backward();
      return true;
    }
    WebUtil.deleteNode(this.learningItem.url);
    WebUtil.createNWeb(this.learningItem.url);

    if (this.learningItem.isLearned === false && this.learnSeconds >= LEARN_MIN_DURATION) {
      this.onDestinationBack(this.learningItem.id);
    } else {
      this.onDestinationBack();
    }
    return true;
  }

  startLearning(): void {
    if (!this.intervalId && (!this.learningItem.isLearned)) {
      this.learnSeconds = 0;
      this.intervalId = setInterval(() => {
        this.learnSeconds++;
        Logger.info(TAG, 'learnSeconds: ' + this.learnSeconds);
        if (this.learnSeconds === LEARN_MIN_DURATION) {
          clearInterval(this.intervalId);
          Logger.info(TAG, 'learning completed');
        }
      }, LearningConstants.ANIMATION_DURATION_NORMAL);
    }
  }

  initWebNode() {
    WebUtil.createNWeb(this.learningItem.url);
    WebUtil.setOnPageEndAction(this.learningItem.url, () => {
      this.startLearning();
    });
    WebUtil.setOnProgressChangeAction(this.learningItem.url, () => {
      WebUtil.getController(this.learningItem.url)?.onCreateNativeMediaPlayer(() => {
        this.showCommentBtn = true;
        return null;
      })
      this.showCommentBtn = false;
      animateTo({ duration: 300 }, () => {
        this.showComment = false;
      });
      // let webUrl: string = WebUtil.getController(this.learningItem.url)?.getUrl() || '';
      // let shouldShow: boolean = webUrl.includes('/content?chapterId=');
      // this.showCommentBtn = this.foldExpanded && shouldShow;
      // if (!shouldShow) {
      //   animateTo({ duration: 300 }, () => {
      //     this.showComment = false;
      //   });
      // }
    })
    WebUtil.setOnResourceLoadAction(this.learningItem.url, (resourceUrl: string) => {
      let shouldShow: boolean = resourceUrl.includes('FileServer/getFile/cmtyPub/103/404/958/');
      if (this.showCommentBtn == false) {
        this.showCommentBtn = this.foldExpanded && shouldShow;
      }
    })
  }

  loadingComments(isFirstLoad: boolean) {
    this.loadingCommentsStatus = true;
    this.learningModel.getLearningComments(this.learningItem.id, isFirstLoad).then(() => {
      this.loadingCommentsStatus = false;
    });
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Column() {
            Row() {
              Image($r('app.media.ic_back'))
                .width($r('app.float.interactive_button_height'))
                .height($r('app.float.interactive_button_height'))
                .margin({ left: $r('app.float.xxl_padding_margin'), right: $r('app.float.lg_padding_margin') })
                .onClick(() => this.onBackPressBack())

              Text(this.learningItem.title)
                .fontSize($r('app.float.title_text_size'))
                .fontWeight(FontWeight.Medium)
                .textAlign(TextAlign.Start)
            }
            .height($r('app.float.navigation_height'))
          }
          .padding({ top: AppStorage.get<number>('statusBarHeight') })

          if (this.foldExpanded && this.showCommentBtn) {
            Column() {
              Row() {
                Text($r('app.string.featured_reviews'))
                  .margin({ left: $r('app.float.xxl_padding_margin') })
                  .fontColor($r('sys.color.ohos_id_color_text_primary'))
                  .fontSize($r('app.float.font_size_large'))
                  .fontWeight(FontWeight.Medium)
                  .visibility(this.showComment ? Visibility.Visible : Visibility.None)
                  .layoutWeight(1)
                Image(this.showComment ? $r('app.media.ic_normal') : $r('app.media.ic_double'))
                  .fillColor($r('sys.color.ohos_id_color_foreground'))
                  .margin({ top: $r('app.float.sm_padding_margin'), right: $r('app.float.xxl_padding_margin') })
                  .width($r('app.float.comment_icon_size'))
                  .aspectRatio(1)
                  .onClick(() => {
                    animateTo({ duration: LearningConstants.SWIPER_DURATION }, () => {
                      this.showComment = !this.showComment;
                      if (this.showComment) {
                        this.loadingComments(true);
                      }
                    });
                  })
              }
              .height($r('app.float.navigation_height'))
              .width(LearningConstants.FULL_PERCENT)
              .justifyContent(FlexAlign.End)
            }
            .padding({ top: AppStorage.get<number>('statusBarHeight') })
            .width(this.showComment ? LearningConstants.HALF_PERCENT : $r('app.float.menu_width'))
            .backgroundColor(this.showComment ? $r('sys.color.ohos_id_color_sub_background') :
            $r('sys.color.ohos_id_color_background'))
          }
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width(LearningConstants.FULL_PERCENT)

        Row() {
          GridRow({
            columns: {
              xs: ColumnEnum.SM,
              sm: ColumnEnum.SM,
              md: ColumnEnum.MD,
              lg: ColumnEnum.LG
            },
            gutter: {
              x: {
                xs: $r('app.float.xxl_padding_margin'),
                sm: $r('app.float.xxl_padding_margin'),
                md: $r('app.float.md_padding_margin'),
                lg: $r('app.float.md_padding_margin')
              }
            },
            breakpoints: { reference: BreakpointsReference.ComponentSize }
          }) {
            GridCol({
              span: {
                xs: SpanEnum.SM,
                sm: SpanEnum.SM,
                md: SpanEnum.MD,
                lg: SpanEnum.LG
              },
              offset: {
                xs: OffsetEnum.SM,
                sm: OffsetEnum.SM,
                md: OffsetEnum.MD,
                lg: OffsetEnum.LG
              }
            }) {
              NodeContainer(WebUtil.getNWeb(this.learningItem.url))
                .width(CommonConstants.FULL_PERCENT)
                .height(CommonConstants.FULL_PERCENT)
            }
          }
          .layoutWeight(1)

          Row() {
            if (this.loadingCommentsStatus) {
              LoadingView()
            } else {
              List() {
                LazyForEach(this.learningModel.learningCommentsDataSource, (item: LearningComment, index: number) => {
                  ListItem() {
                    CommentItem({ item: item })
                      .onAppear(() => {
                        if (!this.loadingCommentsStatus && this.learningModel.hasNextPage &&
                          index + 3 === this.learningCommentsDataSource.dataArray.length) {
                          this.learningModel.getLearningComments(this.learningItem.id, false);
                        }
                      })
                  }
                })
                if (!this.loadingCommentsStatus && !this.learningModel.hasNextPage) {
                  ListItem() {
                    NoMore()
                  }
                }
              }
              .cachedCount(3)
              .padding({ left: $r('app.float.xxl_padding_margin'), right: $r('app.float.xxl_padding_margin') })
              .height(LearningConstants.FULL_PERCENT)
              .width(LearningConstants.FULL_PERCENT)
            }
          }
          .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
          .clip(true)
          .width(this.foldExpanded && this.showComment ? LearningConstants.HALF_PERCENT : 0)
          .height(LearningConstants.FULL_PERCENT)
        }
        .layoutWeight(1)
      }
      .width(LearningConstants.FULL_PERCENT)
      .height(LearningConstants.FULL_PERCENT)
    }
    .height(LearningConstants.FULL_PERCENT)
    .width(LearningConstants.FULL_PERCENT)
    .hideTitleBar(true)
    .onReady((cxt: NavDestinationContext) => {
      let params = cxt.pathInfo.param as Record<string, object>;
      this.learningItem = params.learningItem as LearningPath;
      this.initWebNode();
      continueModel.setData(RouterNameEnum.LEARNING_DETAIL, this.learningItem);
      this.onDestinationBack = params.onDestinationBack as () => boolean;
    })
    .onHidden(() => {
      if (this.intervalId && this.intervalId > -1) {
        clearInterval();
        this.intervalId = undefined;
      }
    })
    .onBackPressed(() => {
      this.onBackPressBack();
      return true;
    })
  }
}

@Builder
export function LearningDetailViewBuilder() {
  LearningDetailView();
}