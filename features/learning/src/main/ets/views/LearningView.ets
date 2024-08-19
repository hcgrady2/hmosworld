/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
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
  ContinueModel,
  EventTypeEnum,
  Logger,
  RouterNameEnum,
  WindowUtil
} from '@ohos/utils';
import { LearningConstants } from '../constants/LearningConstants';
import { LearningPath } from '../model/LearningPath';
import { LearningModel } from '../model/LearningModel';
import { AchievementDialog } from '../components/AchievementDialog';
import { LearningItem } from '../components/LearningItem';

const TAG = '[LearningView]';
let continueModel = ContinueModel.getInstance();

@Component
export struct LearningView {
  @Consume('appPathStack') appPathStack: NavPathStack;
  private eventHub: common.EventHub = (getContext(this) as common.UIAbilityContext).eventHub;
  @Link @Watch('handlePathLearned') learnedId: string;
  @State learningModel: LearningModel = LearningModel.getInstance();
  @State learningItem: LearningPath | null = null;
  @StorageLink('currentBreakpoint') currentBreakpoint: BreakpointTypeEnum = BreakpointTypeEnum.MD;
  achievementDialog: CustomDialogController = new CustomDialogController({
    builder: AchievementDialog({ learningItem: $learningItem }),
    alignment: DialogAlignment.Center,
    autoCancel: false,
    maskColor: $r('app.color.achieve_dialog_mask_color'),
    customStyle: true
  });

  aboutToAppear(): void {
    this.learningModel.init();
    Logger.info(TAG, 'aboutToAppear routerName is:' + continueModel.geRouterName());
    if (continueModel.isContinue && continueModel.data?.routerName === RouterNameEnum.LEARNING_DETAIL) {
      let learningPath: LearningPath = continueModel.data?.itemData as LearningPath;
      this.jumpDetail(learningPath);
    }
    WindowUtil.updateStatusBarColor(getContext(this),
      AppStorage.get('currentColorMode') === ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
  }

  handlePathLearned(): void {
    Logger.info(TAG, 'handlePathLearned');
    Logger.info(TAG, `learnedId:${this.learnedId}`);
    if (this.learnedId) {
      this.learningModel.updateLearnedPath(this.learnedId).then(() => {
        Logger.info(TAG, 'show Dialog');
        this.eventHub.emit(EventTypeEnum.LEARNING, this.learnedId);
        this.learningItem = this.learningModel.getLearningMap().get(this.learnedId) as LearningPath;
        this.achievementDialog.open();
      });
    }
  }

  @Builder
  NaviBar() {
    Row() {
      Text($r('app.string.learning_title'))
        .fontSize($r('app.float.navigation_title_size'))
        .fontWeight(FontWeight.Bold)
        .margin({ left: $r('app.float.navigation_margin') })
    }
    .height($r('app.float.navigation_height'))
    .width(LearningConstants.FULL_PERCENT)
    .justifyContent(FlexAlign.Start)
  }

  jumpDetail(item: LearningPath) {
    this.appPathStack.pushPathByName('LearningDetailView', new Object({
      learningItem: item,
      onDestinationBack: (learningId?: string) => {
        this.appPathStack.pop();
        this.learnedId = learningId || '';
      }
    }));
  }

  build() {
    Column() {
      this.NaviBar();
      List({ space: LearningConstants.LIST_SPACE }) {
        ForEach(this.learningModel.list, (item: LearningPath) => {
          ListItem() {
            LearningItem(item)
          }
          .margin({ right: $r('app.float.md_padding_margin') })
          .onClick(() => {
            this.jumpDetail(item);
          })
        })
      }
      .scrollBar(BarState.Off)
      .padding({ left: $r('app.float.md_padding_margin') })
      .layoutWeight(1)
      .lanes(new BreakpointType({
        sm: LearningConstants.LEARNING_LANES_SM,
        md: LearningConstants.LEARNING_LANES_MD,
        lg: LearningConstants.LEARNING_LANES_LG
      }).getValue(this.currentBreakpoint))
    }
    .width(LearningConstants.FULL_PERCENT)
    .height(LearningConstants.FULL_PERCENT)
    .padding({ top: AppStorage.get<number>('statusBarHeight') })
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }
}