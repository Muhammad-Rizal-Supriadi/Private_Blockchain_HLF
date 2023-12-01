/*
 * SPDX-License-Identifier: Apache-2.0
 */

import { Context, Contract } from 'fabric-contract-api';
import { Intelijen } from './intelijen';

export class Militer extends Contract {

  public async createData(ctx: Context, documentData: string) {
    if (documentData.length === 0) {
      throw new Error(`Tolong masukan data`);
    }

    let militer: Militer ;

    try {
      militer = JSON.parse(documentData);
    } catch (error) {
      throw new Error(`Failed while parsing document. ${error.message}`);
    }
    const docAsBytes = JSON.stringify(militer);
    await ctx.stub.setEvent("CreateAsset", Buffer.from(JSON.stringify(docAsBytes)));
    await ctx.stub.putState(militer.ID, Buffer.from(docAsBytes));
    return ctx.stub.getTxID();
  }

  public async getOneData(ctx: Context, documentID: string): Promise<string> {
    const docAsBytes = await ctx.stub.getState(documentID);
    if (!docAsBytes || docAsBytes.length === 0) {
        throw new Error(`${documentID} tidak ditemukan`);
    }
    return docAsBytes.toString();
  }

  public async fetchData(ctx: Context, documentID: string){
    let query = {
      selector: {
        $and: [
          { _id: { $regex: documentID } }
        ]
      },
      fields: ['DataHash1', 'DataHash2', 'LokasiMusuh', 'KekuatanMusuh', 'RencanaMusuh', 'TeknologiMusuh', 'TitikKumpulMusuh', 'KomunikasiMusuh', 'KelemahanMusuh', 'SasaranStrategis', 'IdentitasIntelijen']
      };
    let iterator = await ctx.stub.getQueryResult(JSON.stringify(query))
    let results = await this._getIteratorData(iterator);
    if (!results || results.length === 0){
      throw new Error(`${documentID} tidak ditemukan`);
    }
    return JSON.stringify(results);
  }

  private async _getIteratorData(iterators: any): Promise<any[]> {
    let resultArray: any[] = [];

    while (true) {
      const res = await iterators.next();
      const resJson: {key: string, value: any} = { key: '', value: null };
      if (res.value && res.value.value.toString()) {
        resJson.key = res.value.key;
        resJson.value = JSON.parse(res.value.value.toString('utf-8'));
        resultArray.push(resJson);
      }
      if (res.done) {
        await iterators.close();
        return resultArray;
      }
    }
  }
}
