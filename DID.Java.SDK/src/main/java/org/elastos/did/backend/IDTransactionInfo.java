/*
 * Copyright (c) 2019 Elastos Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

package org.elastos.did.backend;

import java.io.IOException;
import java.util.Date;

import org.elastos.did.Constants;
import org.elastos.did.DID;
import org.elastos.did.exception.DIDResolveException;
import org.elastos.did.util.JsonHelper;

import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.databind.JsonNode;

public class IDTransactionInfo {
	private String txId;
	private Date timestamp;
	private IDChainRequest request;

	public IDTransactionInfo(String txid, Date timestamp,
			IDChainRequest request) {
		this.txId = txid;
		this.timestamp = timestamp;
		this.request = request;
	}

	public String getTransactionId() {
		return txId;
	}

	public Date getTimestamp() {
		return timestamp;
	}

	public DID getDid() {
		return request.getDid();
	}

	public IDChainRequest.Operation getOperation() {
		return request.getOperation();
	}

	public String getPayload() {
		return request.toJson(false);
	}

	public IDChainRequest getRequest() {
		return request;
	}

	public void toJson(JsonGenerator generator) throws IOException {
		generator.writeStartObject();
		generator.writeStringField(Constants.txid, getTransactionId());
		generator.writeStringField(Constants.timestamp,
				JsonHelper.format(getTimestamp()));
		generator.writeFieldName(Constants.operation);
		request.toJson(generator, false);
		generator.writeEndObject();
	}

	public static IDTransactionInfo fromJson(JsonNode node)
			throws DIDResolveException {
		Class<DIDResolveException> exceptionClass = DIDResolveException.class;

		if (node == null || node.size() == 0)
			return null;

		String txid = JsonHelper.getString(node, Constants.txid, false, null,
				"transaction id", exceptionClass);

		Date timestamp = JsonHelper.getDate(node, Constants.timestamp, false,
				null, "transaction timestamp", exceptionClass);

		JsonNode reqNode = node.get(Constants.operation);
		if (reqNode == null)
			throw new DIDResolveException("Missing ID operation.");

		IDChainRequest request = IDChainRequest.fromJson(reqNode);

		return new IDTransactionInfo(txid, timestamp, request);
	}
}
