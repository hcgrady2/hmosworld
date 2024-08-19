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

import { fileIo, fileUri } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
import Logger from './Logger';

const TAG: string = '[FileUtil]';

export class FileUtil {
  public static copyFile(src: string, dest: string): void {
    Logger.info(TAG, 'copyFile path src: ' + src);
    Logger.info(TAG, 'copyFile path dest: ' + dest);
    try {
      let srcFile = fileIo.openSync(src, fileIo.OpenMode.READ_ONLY);
      let distFile = fileIo.openSync(dest, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      fileIo.copyFileSync(srcFile.fd, distFile.fd);
      fileIo.closeSync(srcFile);
      fileIo.closeSync(distFile);
      Logger.info(TAG, 'copyFile success');
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.error(TAG, `copyFile failed code: ${err.code}, message: ${err.message}`);
    }
  }

  public static deleteFile(filePath: string): void {
    Logger.info(TAG, 'rmdir deleteFile:' + filePath);
    fileIo.rmdir(filePath, (err: BusinessError) => {
      if (err) {
        Logger.error(TAG, `deleteFile failed code: ${err.code}, message: ${err.message}`);
      } else {
        Logger.info(TAG, 'deleteFile succeed');
      }
    });
  }

  public static saveBuffer2File(filePath: string, buffer: ArrayBuffer): void {
    Logger.info(TAG, 'saveBuffer2File filePath:' + filePath);
    try {
      let distFile = fileIo.openSync(filePath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      fileIo.write(distFile.fd, buffer);
      fileIo.closeSync(distFile.fd)
      Logger.info(TAG, 'saveBuffer2File success');
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      Logger.error(TAG, `saveBuffer2File failed code: ${err.code}, message: ${err.message}`);
    }
  }

  public static getFileUri(filePath: string): string {
    return fileUri.getUriFromPath(filePath);
  }

  public static savePixelMap2File(pixelMap: PixelMap, filePath: string) {
    Logger.info(TAG, 'savePixelMap2File filePath:' + filePath);
    let packOpts: image.PackingOption = { format: "image/png ", quality: 100 };
    let file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
    let imagePackerApi = image.createImagePacker();
    imagePackerApi.packToFile(pixelMap, file.fd, packOpts).then(() => {
      Logger.info(TAG, 'savePixelMap2File success');
      fileIo.closeSync(file.fd);
    }).catch((err: BusinessError) => {
      fileIo.closeSync(file.fd);
      Logger.error(TAG, `savePixelMap2File failed code: ${err.code}, message: ${err.message}`);
    })
  }
}