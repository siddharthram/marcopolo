package com.marcopolo.service.aws;

/*
 * Copyright 2010 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */
import java.io.ByteArrayInputStream;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.codec.digest.DigestUtils;

import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.CannedAccessControlList;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.PutObjectRequest;
import com.amazonaws.services.s3.model.PutObjectResult;

public class S3StoreImage {
	private static final String awsAccessKeyId = "AKIAIGP5BWDMWRRINTSQ";
	private static final String key = "SNZNbO2QlOAdpZc19BLlbgz7HoVLTOnHOMteClge";
	private static final String bucketName = "ximly_test1";

	public static String storeS3File(String uuid, byte[] data) {
		String returnUrl = "https://s3.amazonaws.com/" + bucketName + "/" + uuid;
		AmazonS3 s3 = new AmazonS3Client(new BasicAWSCredentials(
				awsAccessKeyId, key));
		putObject(s3, bucketName, uuid, data);
		return returnUrl;
	}

	private static PutObjectResult putObject(AmazonS3 s3Client, String bucket,
			String uuid, byte[] data) {
		ByteArrayInputStream input = new ByteArrayInputStream(data);
		ObjectMetadata metadata = new ObjectMetadata();
		metadata.setContentLength(data.length);
		metadata.setContentMD5(Base64.encodeBase64String(DigestUtils.md5(data)));
		PutObjectRequest putObjectRequest = new PutObjectRequest(bucket, uuid, input, metadata);
        putObjectRequest.withCannedAcl(CannedAccessControlList.PublicRead); // public for all
		
		return s3Client.putObject(putObjectRequest);
	}

}
