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

import { Want } from '@kit.AbilityKit';
import { buffer } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { formInfo, formBindingData, FormExtensionAbility } from '@kit.FormKit';
import cloud from '@hw-agconnect/cloud';
import { initialize, Logger } from '@hw-agconnect/hmcore';
import pushService from '@hms.core.push.pushService';
import { FORM_DATA, PROXY_KEYS } from '../model/CardModel';

const TAG = '[EntryFormAbility]';

export default class EntryFormAbility extends FormExtensionAbility {
  async initAgc() {
    const context = this.context;
    const value = await context.resourceManager.getRawFileContent('agconnect-services.json');
    let json: string = buffer.from(value as ArrayBuffer).toString('utf8');
    initialize(this.context, JSON.parse(json));
  }

  async uploadFormInfo(formId: string) {
    Logger.info(TAG, 'formId', '%{public}s', 'formId ' + formId + 'start');
    try {
      pushService.getToken((err: BusinessError, data: string) => {
        if (err) {
          Logger.error(TAG, 'Get push token failed: ' + JSON.stringify(err));
        } else {
          Logger.info(TAG, 'Get push token successfully: %{public}s.', data);
          cloud.callFunction({
            name: 'forminfo',
            version: '$latest',
            params: {
              'token': data,
              'formId': formId
            }
          }).then((res) => {
            Logger.info(TAG, 'Upload FormId and Token success' + JSON.stringify(res));
          }).catch((error: Error) => {
            Logger.info(TAG, 'Upload FormId and Token error: ' + error);
          });
        }
      });
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      Logger.error(TAG, 'Get push token catch error: %{public}d %{public}s', e.code, e.message);
    }
  }

  onAddForm(want: Want) {
    Logger.info(TAG, `onAddForm ${JSON.stringify(this.context.getApplicationContext())}`)
    // Get formId.
    let formId: string = want.parameters ? want.parameters[formInfo.FormParam.IDENTITY_KEY] as string : '';
    Logger.info(TAG, 'onAddForm  formId' + formId);
    try {
      this.initAgc();
      this.uploadFormInfo(formId)

      Logger.info(TAG, 'AGC init AGC SDK success');
    } catch (err) {
      Logger.error(TAG, 'AGC init AGC SDK failed ' + err);
    }

    // Called to return a FormBindingData object.
    Logger.info(TAG, 'onAddForm');
    const bindingData: formBindingData.FormBindingData = formBindingData.createFormBindingData(FORM_DATA);
    // Define the fields that need to be updated through the push service proxy.
    // Each key must be defined in bindingData.
    let proxyList: formBindingData.ProxyData[] = [];
    for (let i = 0; i < PROXY_KEYS.length; i++) {
      let proxyData: formBindingData.ProxyData = {
        key: PROXY_KEYS[i],
        subscriberId: formId,
      };
      proxyList.push(proxyData);
    }
    bindingData.proxies = proxyList;
    return bindingData;
  }

  onCastToNormalForm(formId: string) {
    // Called when the form provider is notified that a temporary form is successfully
    // converted to a normal form.
    Logger.info(TAG, `onCastToNormalForm, formId: ${formId}`);
  }

  onUpdateForm(formId: string) {
    // Called to notify the form provider to update a specified form.
    // this.cardService.updateForm();
    Logger.info(TAG, `onUpdateForm`);
  }

  onChangeFormVisibility(newStatus: Record<string, number>) {
    // Called when the form provider receives form events from the system.
  }

  onFormEvent(formId: string, message: string) {
    // Called when a specified message event defined by the form provider is triggered.
  }

  onRemoveForm(formId: string) {
    Logger.info(TAG, ` onCastToNormalForm, formId: ${formId}`);
    // Called to notify the form provider that a specified form has been destroyed.
    this.removeFormInfo(formId);
  }

  async removeFormInfo(formId: string) {
    Logger.info(TAG, `onCastToNormalForm, removeFormInfo`);
    try {
      await this.initAgc();
      pushService.getToken((err: BusinessError, data: string) => {
        if (err) {
          Logger.error(TAG, 'Get push token failed: %{public}d %{public}s', err.code, err.message);
        } else {
          Logger.info(TAG, 'Get push token successfully: %{public}s.', data);
          cloud.callFunction({
            name: 'removeforminfo',
            version: '$latest',
            params: {
              'token': data,
              'formId': formId
            }
          }).then((res) => {
            Logger.info(TAG, 'Remove FormId and Token success' + JSON.stringify(res));
          }).catch((error: Error) => {
            Logger.info(TAG, 'Remove FormId and Token error: ' + error);
          });
        }
      });
    } catch (err) {
      let e: BusinessError = err as BusinessError;
      Logger.error(TAG, 'Get push token catch error: %{public}d %{public}s', e.code, e.message);
    }
  }

  onAcquireFormState(want: Want) {
    // Called to return a {@link FormState} object.
    return formInfo.FormState.READY;
  }
};