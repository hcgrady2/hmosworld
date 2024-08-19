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

import {
  abilityAccessCtrl,
  AbilityConstant,
  bundleManager,
  common,
  Permissions,
  UIAbility,
  Want
} from '@kit.AbilityKit';
import { buffer } from '@kit.ArkTS';
import { webview } from '@kit.ArkWeb';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { formInfo } from '@kit.FormKit';
import { notificationManager } from '@kit.NotificationKit';
import { initialize } from '@hw-agconnect/hmcore';
import { AudioRenderService, SpeechPlayerService } from '@ohos/audioplayer';
import { CData, ContinueModel, GlobalContext, Logger, WindowUtil } from '@ohos/utils';
import { AppConstants } from '../constants/AppConstants';

const TAG = '[EntryAbility]';
let localStorage: LocalStorage = new LocalStorage();

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'Ability onCreate');
    this.initAgc();
    this.handleParams(want);
    this.restoringData(want, launchParam);
    this.requestNotification();
    this.initWebEngine();
    AppStorage.setOrCreate('systemColorMode', this.context.config.colorMode);
    this.onConfigurationUpdate(this.context.config);
    WindowUtil.setMissionContinueActive(this.context, false);
  }

  requestNotification() {
    notificationManager.requestEnableNotification(this.context).then(() => {
      Logger.info('requestEnableNotification success');
      this.checkPermissions();
    }).catch((err: BusinessError) => {
      this.checkPermissions();
      Logger.error(`requestEnableNotification fail: ${JSON.stringify(err)}`);
    });
  }

  handleParams(want: Want): void {
    // 卡片更新和推送消息过来的参数
    if (want.parameters && (want.parameters[formInfo.FormParam.IDENTITY_KEY] || want.parameters.articleId)) {
      Logger.info(TAG, 'onNewWant parameters:' + JSON.stringify(want.parameters));
      GlobalContext.getContext().setObject('articleId', want.parameters.articleId);
      GlobalContext.getContext().setObject('type', want.parameters.type);
      GlobalContext.getContext().setObject('webUrl', want.parameters.webUrl);
    }
  }

  async initAgc() {
    const value = await this.context.resourceManager.getRawFileContent('agconnect-services.json');
    let json: string = buffer.from(value as ArrayBuffer).toString('utf8');
    initialize(this.context, JSON.parse(json));
  }

  initWebEngine() {
    setTimeout(() => {
      webview.WebviewController.initializeWebEngine();
    }, 0);
  }

  onDestroy(): void {
    Logger.info(TAG, 'Ability onDestroy');
    SpeechPlayerService.getInstance().releaseTextToSpeechEngine();
    AudioRenderService.getInstance().releaseAudioRender();
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    Logger.info(TAG, 'Ability onWindowStageCreate');
    AppStorage.setOrCreate<number>('statusBarHeight', AppConstants.DEFAULT_STATUS_HEIGHT);
    AppStorage.setOrCreate<window.WindowStage>('windowStage', windowStage);
    AppStorage.setOrCreate<common.UIAbilityContext>('uiAbilityContext', this.context);
    WindowUtil.requestFullScreen(windowStage, this.context);
    windowStage.loadContent('pages/SplashPage', localStorage);
  }

  onWindowStageRestore(windowStage: window.WindowStage): void {
    AppStorage.setOrCreate<number>('statusBarHeight', AppConstants.DEFAULT_STATUS_HEIGHT);
    AppStorage.setOrCreate<window.WindowStage>('windowStage', windowStage);
    WindowUtil.requestFullScreen(windowStage, this.context);
    Logger.info(TAG, 'Ability onWindowStageRestore');
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    Logger.info(TAG, 'onNewWant want:' + JSON.stringify(want));
    this.handleParams(want);
    this.restoringData(want, launchParam);
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    Logger.info(TAG, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    Logger.info(TAG, 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    Logger.info(TAG, 'Ability onBackground');
  }

  async checkPermissions(): Promise<void> {
    const permissions: Array<Permissions> = ["ohos.permission.DISTRIBUTED_DATASYNC"];
    const accessManager = abilityAccessCtrl.createAtManager();
    try {
      const bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION;
      const bundleInfo = await bundleManager.getBundleInfoForSelf(bundleFlags);
      const grantStatus = await accessManager.checkAccessToken(bundleInfo.appInfo.accessTokenId, permissions[0]);
      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
        accessManager.requestPermissionsFromUser(this.context, permissions)
      }
    } catch (err) {
      Logger.error('EntryAbility', 'checkPermissions', `Catch err: ${err}`);
      return;
    }
  }

  onContinue(wantParam: Record<string, Object>): AbilityConstant.OnContinueResult {
    Logger.info(TAG, 'onContinue continueData:' + JSON.stringify(ContinueModel.getInstance().data));
    wantParam.continueData = JSON.stringify(ContinueModel.getInstance().data);
    return AbilityConstant.OnContinueResult.AGREE;
  }

  async restoringData(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    // Recovering migrated data from want.
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      if (want.parameters && want.parameters.continueData) {
        Logger.info(TAG, 'restoringData parameters:' + JSON.stringify(want.parameters.continueData));
        let cData = JSON.parse(want.parameters.continueData as string) as CData
        let userId = (cData.userData as Record<string, string>).id as string;
        ContinueModel.getInstance().data = cData;
        ContinueModel.getInstance().isContinue = true;
        if (userId) {
          AppStorage.setOrCreate('userId', userId);
          AppStorage.setOrCreate('isLogged', true);
        }
      }
      this.context.restoreWindowStage(localStorage);
    }
  }
}
