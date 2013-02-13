/**
 * Autogenerated by Thrift Compiler (1.0.0-dev)
 *
 * DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
 *  @generated
 */

#import <Foundation/Foundation.h>

#import "TProtocol.h"
#import "TApplicationException.h"
#import "TProtocolUtil.h"
#import "TProcessor.h"
#import "TObjective-C.h"


#import "EDAMLimits.h"

static int32_t EDAMEDAM_ATTRIBUTE_LEN_MIN = 1;
static int32_t EDAMEDAM_ATTRIBUTE_LEN_MAX = 4096;
static NSString * EDAMEDAM_ATTRIBUTE_REGEX = @"^[^\\p{Cc}\\p{Zl}\\p{Zp}]{1,4096}$";
static int32_t EDAMEDAM_ATTRIBUTE_LIST_MAX = 100;
static int32_t EDAMEDAM_ATTRIBUTE_MAP_MAX = 100;
static int32_t EDAMEDAM_GUID_LEN_MIN = 36;
static int32_t EDAMEDAM_GUID_LEN_MAX = 36;
static NSString * EDAMEDAM_GUID_REGEX = @"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$";
static int32_t EDAMEDAM_EMAIL_LEN_MIN = 6;
static int32_t EDAMEDAM_EMAIL_LEN_MAX = 255;
static NSString * EDAMEDAM_EMAIL_LOCAL_REGEX = @"^[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+(\\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*$";
static NSString * EDAMEDAM_EMAIL_DOMAIN_REGEX = @"^[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*\\.([A-Za-z]{2,})$";
static NSString * EDAMEDAM_EMAIL_REGEX = @"^[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+(\\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*\\.([A-Za-z]{2,})$";
static NSString * EDAMEDAM_VAT_REGEX = @"[A-Za-z]{2}.+";
static int32_t EDAMEDAM_TIMEZONE_LEN_MIN = 1;
static int32_t EDAMEDAM_TIMEZONE_LEN_MAX = 32;
static NSString * EDAMEDAM_TIMEZONE_REGEX = @"^([A-Za-z_-]+(/[A-Za-z_-]+)*)|(GMT(-|\\+)[0-9]{1,2}(:[0-9]{2})?)$";
static int32_t EDAMEDAM_MIME_LEN_MIN = 3;
static int32_t EDAMEDAM_MIME_LEN_MAX = 255;
static NSString * EDAMEDAM_MIME_REGEX = @"^[A-Za-z]+/[A-Za-z0-9._+-]+$";
static NSString * EDAMEDAM_MIME_TYPE_GIF = @"image/gif";
static NSString * EDAMEDAM_MIME_TYPE_JPEG = @"image/jpeg";
static NSString * EDAMEDAM_MIME_TYPE_PNG = @"image/png";
static NSString * EDAMEDAM_MIME_TYPE_WAV = @"audio/wav";
static NSString * EDAMEDAM_MIME_TYPE_MP3 = @"audio/mpeg";
static NSString * EDAMEDAM_MIME_TYPE_AMR = @"audio/amr";
static NSString * EDAMEDAM_MIME_TYPE_AAC = @"audio/aac";
static NSString * EDAMEDAM_MIME_TYPE_M4A = @"audio/mp4";
static NSString * EDAMEDAM_MIME_TYPE_MP4_VIDEO = @"video/mp4";
static NSString * EDAMEDAM_MIME_TYPE_INK = @"application/vnd.evernote.ink";
static NSString * EDAMEDAM_MIME_TYPE_PDF = @"application/pdf";
static NSString * EDAMEDAM_MIME_TYPE_DEFAULT = @"application/octet-stream";
static NSMutableSet * EDAMEDAM_MIME_TYPES;
static int32_t EDAMEDAM_SEARCH_QUERY_LEN_MIN = 0;
static int32_t EDAMEDAM_SEARCH_QUERY_LEN_MAX = 1024;
static NSString * EDAMEDAM_SEARCH_QUERY_REGEX = @"^[^\\p{Cc}\\p{Zl}\\p{Zp}]{0,1024}$";
static int32_t EDAMEDAM_HASH_LEN = 16;
static int32_t EDAMEDAM_USER_USERNAME_LEN_MIN = 1;
static int32_t EDAMEDAM_USER_USERNAME_LEN_MAX = 64;
static NSString * EDAMEDAM_USER_USERNAME_REGEX = @"^[a-z0-9]([a-z0-9_-]{0,62}[a-z0-9])?$";
static int32_t EDAMEDAM_USER_NAME_LEN_MIN = 1;
static int32_t EDAMEDAM_USER_NAME_LEN_MAX = 255;
static NSString * EDAMEDAM_USER_NAME_REGEX = @"^[^\\p{Cc}\\p{Zl}\\p{Zp}]{1,255}$";
static int32_t EDAMEDAM_TAG_NAME_LEN_MIN = 1;
static int32_t EDAMEDAM_TAG_NAME_LEN_MAX = 100;
static NSString * EDAMEDAM_TAG_NAME_REGEX = @"^[^,\\p{Cc}\\p{Z}]([^,\\p{Cc}\\p{Zl}\\p{Zp}]{0,98}[^,\\p{Cc}\\p{Z}])?$";
static int32_t EDAMEDAM_NOTE_TITLE_LEN_MIN = 1;
static int32_t EDAMEDAM_NOTE_TITLE_LEN_MAX = 255;
static NSString * EDAMEDAM_NOTE_TITLE_REGEX = @"^[^\\p{Cc}\\p{Z}]([^\\p{Cc}\\p{Zl}\\p{Zp}]{0,253}[^\\p{Cc}\\p{Z}])?$";
static int32_t EDAMEDAM_NOTE_CONTENT_LEN_MIN = 0;
static int32_t EDAMEDAM_NOTE_CONTENT_LEN_MAX = 5242880;
static int32_t EDAMEDAM_APPLICATIONDATA_NAME_LEN_MIN = 3;
static int32_t EDAMEDAM_APPLICATIONDATA_NAME_LEN_MAX = 32;
static int32_t EDAMEDAM_APPLICATIONDATA_VALUE_LEN_MIN = 0;
static int32_t EDAMEDAM_APPLICATIONDATA_VALUE_LEN_MAX = 4092;
static int32_t EDAMEDAM_APPLICATIONDATA_ENTRY_LEN_MAX = 4095;
static NSString * EDAMEDAM_APPLICATIONDATA_NAME_REGEX = @"^[A-Za-z0-9_.-]{3,32}$";
static NSString * EDAMEDAM_APPLICATIONDATA_VALUE_REGEX = @"^[^\\p{Cc}]{0,4092}$";
static int32_t EDAMEDAM_NOTEBOOK_NAME_LEN_MIN = 1;
static int32_t EDAMEDAM_NOTEBOOK_NAME_LEN_MAX = 100;
static NSString * EDAMEDAM_NOTEBOOK_NAME_REGEX = @"^[^\\p{Cc}\\p{Z}]([^\\p{Cc}\\p{Zl}\\p{Zp}]{0,98}[^\\p{Cc}\\p{Z}])?$";
static int32_t EDAMEDAM_NOTEBOOK_STACK_LEN_MIN = 1;
static int32_t EDAMEDAM_NOTEBOOK_STACK_LEN_MAX = 100;
static NSString * EDAMEDAM_NOTEBOOK_STACK_REGEX = @"^[^\\p{Cc}\\p{Z}]([^\\p{Cc}\\p{Zl}\\p{Zp}]{0,98}[^\\p{Cc}\\p{Z}])?$";
static int32_t EDAMEDAM_PUBLISHING_URI_LEN_MIN = 1;
static int32_t EDAMEDAM_PUBLISHING_URI_LEN_MAX = 255;
static NSString * EDAMEDAM_PUBLISHING_URI_REGEX = @"^[a-zA-Z0-9.~_+-]{1,255}$";
static NSMutableSet * EDAMEDAM_PUBLISHING_URI_PROHIBITED;
static int32_t EDAMEDAM_PUBLISHING_DESCRIPTION_LEN_MIN = 1;
static int32_t EDAMEDAM_PUBLISHING_DESCRIPTION_LEN_MAX = 200;
static NSString * EDAMEDAM_PUBLISHING_DESCRIPTION_REGEX = @"^[^\\p{Cc}\\p{Z}]([^\\p{Cc}\\p{Zl}\\p{Zp}]{0,198}[^\\p{Cc}\\p{Z}])?$";
static int32_t EDAMEDAM_SAVED_SEARCH_NAME_LEN_MIN = 1;
static int32_t EDAMEDAM_SAVED_SEARCH_NAME_LEN_MAX = 100;
static NSString * EDAMEDAM_SAVED_SEARCH_NAME_REGEX = @"^[^\\p{Cc}\\p{Z}]([^\\p{Cc}\\p{Zl}\\p{Zp}]{0,98}[^\\p{Cc}\\p{Z}])?$";
static int32_t EDAMEDAM_USER_PASSWORD_LEN_MIN = 6;
static int32_t EDAMEDAM_USER_PASSWORD_LEN_MAX = 64;
static NSString * EDAMEDAM_USER_PASSWORD_REGEX = @"^[A-Za-z0-9!#$%&'()*+,./:;<=>?@^_`{|}~\\[\\]\\\\-]{6,64}$";
static int32_t EDAMEDAM_BUSINESS_URI_LEN_MAX = 32;
static int32_t EDAMEDAM_NOTE_TAGS_MAX = 100;
static int32_t EDAMEDAM_NOTE_RESOURCES_MAX = 1000;
static int32_t EDAMEDAM_USER_TAGS_MAX = 100000;
static int32_t EDAMEDAM_BUSINESS_TAGS_MAX = 100000;
static int32_t EDAMEDAM_USER_SAVED_SEARCHES_MAX = 100;
static int32_t EDAMEDAM_USER_NOTES_MAX = 100000;
static int32_t EDAMEDAM_BUSINESS_NOTES_MAX = 500000;
static int32_t EDAMEDAM_USER_NOTEBOOKS_MAX = 250;
static int32_t EDAMEDAM_BUSINESS_NOTEBOOKS_MAX = 5000;
static int32_t EDAMEDAM_USER_RECENT_MAILED_ADDRESSES_MAX = 10;
static int32_t EDAMEDAM_USER_MAIL_LIMIT_DAILY_FREE = 50;
static int32_t EDAMEDAM_USER_MAIL_LIMIT_DAILY_PREMIUM = 200;
static int64_t EDAMEDAM_USER_UPLOAD_LIMIT_FREE = 62914560;
static int64_t EDAMEDAM_USER_UPLOAD_LIMIT_PREMIUM = 1073741824;
static int64_t EDAMEDAM_USER_UPLOAD_LIMIT_BUSINESS = 1073741824;
static int32_t EDAMEDAM_NOTE_SIZE_MAX_FREE = 26214400;
static int32_t EDAMEDAM_NOTE_SIZE_MAX_PREMIUM = 104857600;
static int32_t EDAMEDAM_RESOURCE_SIZE_MAX_FREE = 26214400;
static int32_t EDAMEDAM_RESOURCE_SIZE_MAX_PREMIUM = 104857600;
static int32_t EDAMEDAM_USER_LINKED_NOTEBOOK_MAX = 100;
static int32_t EDAMEDAM_NOTEBOOK_SHARED_NOTEBOOK_MAX = 250;
static int32_t EDAMEDAM_NOTE_CONTENT_CLASS_LEN_MIN = 3;
static int32_t EDAMEDAM_NOTE_CONTENT_CLASS_LEN_MAX = 32;
static NSString * EDAMEDAM_HELLO_APP_CONTENT_CLASS_PREFIX = @"evernote.hello.";
static NSString * EDAMEDAM_FOOD_APP_CONTENT_CLASS_PREFIX = @"evernote.food.";
static NSString * EDAMEDAM_NOTE_CONTENT_CLASS_REGEX = @"^[A-Za-z0-9_.-]{3,32}$";
static NSString * EDAMEDAM_CONTENT_CLASS_HELLO_ENCOUNTER = @"evernote.hello.encounter";
static NSString * EDAMEDAM_CONTENT_CLASS_HELLO_PROFILE = @"evernote.hello.profile";
static NSString * EDAMEDAM_CONTENT_CLASS_FOOD_MEAL = @"evernote.food.meal";
static NSString * EDAMEDAM_CONTENT_CLASS_SKITCH = @"evernote.skitch";
static NSString * EDAMEDAM_CONTENT_CLASS_PENULTIMATE = @"evernote.penultimate";
static int32_t EDAMEDAM_RELATED_PLAINTEXT_LEN_MIN = 1;
static int32_t EDAMEDAM_RELATED_PLAINTEXT_LEN_MAX = 131072;
static int32_t EDAMEDAM_RELATED_MAX_NOTES = 25;
static int32_t EDAMEDAM_RELATED_MAX_NOTEBOOKS = 1;
static int32_t EDAMEDAM_RELATED_MAX_TAGS = 25;
static int32_t EDAMEDAM_BUSINESS_NOTEBOOK_DESCRIPTION_LEN_MIN = 1;
static int32_t EDAMEDAM_BUSINESS_NOTEBOOK_DESCRIPTION_LEN_MAX = 200;
static NSString * EDAMEDAM_BUSINESS_NOTEBOOK_DESCRIPTION_REGEX = @"^[^\\p{Cc}\\p{Z}]([^\\p{Cc}\\p{Zl}\\p{Zp}]{0,198}[^\\p{Cc}\\p{Z}])?$";
static int32_t EDAMEDAM_PREFERENCE_NAME_LEN_MIN = 3;
static int32_t EDAMEDAM_PREFERENCE_NAME_LEN_MAX = 32;
static int32_t EDAMEDAM_PREFERENCE_VALUE_LEN_MIN = 1;
static int32_t EDAMEDAM_PREFERENCE_VALUE_LEN_MAX = 1024;
static int32_t EDAMEDAM_MAX_PREFERENCES = 100;
static int32_t EDAMEDAM_MAX_VALUES_PER_PREFERENCE = 250;
static NSString * EDAMEDAM_PREFERENCE_NAME_REGEX = @"^[A-Za-z0-9_.-]{3,32}$";
static NSString * EDAMEDAM_PREFERENCE_VALUE_REGEX = @"^[^\\p{Cc}]{1,1024}$";
static int32_t EDAMEDAM_DEVICE_ID_LEN_MAX = 32;
static NSString * EDAMEDAM_DEVICE_ID_REGEX = @"^[^\\p{Cc}]{1,32}$";
static int32_t EDAMEDAM_DEVICE_DESCRIPTION_LEN_MAX = 64;
static NSString * EDAMEDAM_DEVICE_DESCRIPTION_REGEX = @"^[^\\p{Cc}]{1,64}$";

@implementation EDAMLimitsConstants
+ (void) initialize {
  EDAMEDAM_MIME_TYPES = [[NSMutableSet alloc] initWithCapacity:11];
  [EDAMEDAM_MIME_TYPES addObject:@"image/gif"];
  [EDAMEDAM_MIME_TYPES addObject:@"image/jpeg"];
  [EDAMEDAM_MIME_TYPES addObject:@"image/png"];
  [EDAMEDAM_MIME_TYPES addObject:@"audio/wav"];
  [EDAMEDAM_MIME_TYPES addObject:@"audio/mpeg"];
  [EDAMEDAM_MIME_TYPES addObject:@"audio/amr"];
  [EDAMEDAM_MIME_TYPES addObject:@"application/vnd.evernote.ink"];
  [EDAMEDAM_MIME_TYPES addObject:@"application/pdf"];
  [EDAMEDAM_MIME_TYPES addObject:@"video/mp4"];
  [EDAMEDAM_MIME_TYPES addObject:@"audio/aac"];
  [EDAMEDAM_MIME_TYPES addObject:@"audio/mp4"];

;
  EDAMEDAM_PUBLISHING_URI_PROHIBITED = [[NSMutableSet alloc] initWithCapacity:1];
  [EDAMEDAM_PUBLISHING_URI_PROHIBITED addObject:@".."];

;
}
+ (int32_t) EDAM_ATTRIBUTE_LEN_MIN{
  return EDAMEDAM_ATTRIBUTE_LEN_MIN;
}
+ (int32_t) EDAM_ATTRIBUTE_LEN_MAX{
  return EDAMEDAM_ATTRIBUTE_LEN_MAX;
}
+ (NSString *) EDAM_ATTRIBUTE_REGEX{
  return EDAMEDAM_ATTRIBUTE_REGEX;
}
+ (int32_t) EDAM_ATTRIBUTE_LIST_MAX{
  return EDAMEDAM_ATTRIBUTE_LIST_MAX;
}
+ (int32_t) EDAM_ATTRIBUTE_MAP_MAX{
  return EDAMEDAM_ATTRIBUTE_MAP_MAX;
}
+ (int32_t) EDAM_GUID_LEN_MIN{
  return EDAMEDAM_GUID_LEN_MIN;
}
+ (int32_t) EDAM_GUID_LEN_MAX{
  return EDAMEDAM_GUID_LEN_MAX;
}
+ (NSString *) EDAM_GUID_REGEX{
  return EDAMEDAM_GUID_REGEX;
}
+ (int32_t) EDAM_EMAIL_LEN_MIN{
  return EDAMEDAM_EMAIL_LEN_MIN;
}
+ (int32_t) EDAM_EMAIL_LEN_MAX{
  return EDAMEDAM_EMAIL_LEN_MAX;
}
+ (NSString *) EDAM_EMAIL_LOCAL_REGEX{
  return EDAMEDAM_EMAIL_LOCAL_REGEX;
}
+ (NSString *) EDAM_EMAIL_DOMAIN_REGEX{
  return EDAMEDAM_EMAIL_DOMAIN_REGEX;
}
+ (NSString *) EDAM_EMAIL_REGEX{
  return EDAMEDAM_EMAIL_REGEX;
}
+ (NSString *) EDAM_VAT_REGEX{
  return EDAMEDAM_VAT_REGEX;
}
+ (int32_t) EDAM_TIMEZONE_LEN_MIN{
  return EDAMEDAM_TIMEZONE_LEN_MIN;
}
+ (int32_t) EDAM_TIMEZONE_LEN_MAX{
  return EDAMEDAM_TIMEZONE_LEN_MAX;
}
+ (NSString *) EDAM_TIMEZONE_REGEX{
  return EDAMEDAM_TIMEZONE_REGEX;
}
+ (int32_t) EDAM_MIME_LEN_MIN{
  return EDAMEDAM_MIME_LEN_MIN;
}
+ (int32_t) EDAM_MIME_LEN_MAX{
  return EDAMEDAM_MIME_LEN_MAX;
}
+ (NSString *) EDAM_MIME_REGEX{
  return EDAMEDAM_MIME_REGEX;
}
+ (NSString *) EDAM_MIME_TYPE_GIF{
  return EDAMEDAM_MIME_TYPE_GIF;
}
+ (NSString *) EDAM_MIME_TYPE_JPEG{
  return EDAMEDAM_MIME_TYPE_JPEG;
}
+ (NSString *) EDAM_MIME_TYPE_PNG{
  return EDAMEDAM_MIME_TYPE_PNG;
}
+ (NSString *) EDAM_MIME_TYPE_WAV{
  return EDAMEDAM_MIME_TYPE_WAV;
}
+ (NSString *) EDAM_MIME_TYPE_MP3{
  return EDAMEDAM_MIME_TYPE_MP3;
}
+ (NSString *) EDAM_MIME_TYPE_AMR{
  return EDAMEDAM_MIME_TYPE_AMR;
}
+ (NSString *) EDAM_MIME_TYPE_AAC{
  return EDAMEDAM_MIME_TYPE_AAC;
}
+ (NSString *) EDAM_MIME_TYPE_M4A{
  return EDAMEDAM_MIME_TYPE_M4A;
}
+ (NSString *) EDAM_MIME_TYPE_MP4_VIDEO{
  return EDAMEDAM_MIME_TYPE_MP4_VIDEO;
}
+ (NSString *) EDAM_MIME_TYPE_INK{
  return EDAMEDAM_MIME_TYPE_INK;
}
+ (NSString *) EDAM_MIME_TYPE_PDF{
  return EDAMEDAM_MIME_TYPE_PDF;
}
+ (NSString *) EDAM_MIME_TYPE_DEFAULT{
  return EDAMEDAM_MIME_TYPE_DEFAULT;
}
+ (NSMutableSet *) EDAM_MIME_TYPES{
  return EDAMEDAM_MIME_TYPES;
}
+ (int32_t) EDAM_SEARCH_QUERY_LEN_MIN{
  return EDAMEDAM_SEARCH_QUERY_LEN_MIN;
}
+ (int32_t) EDAM_SEARCH_QUERY_LEN_MAX{
  return EDAMEDAM_SEARCH_QUERY_LEN_MAX;
}
+ (NSString *) EDAM_SEARCH_QUERY_REGEX{
  return EDAMEDAM_SEARCH_QUERY_REGEX;
}
+ (int32_t) EDAM_HASH_LEN{
  return EDAMEDAM_HASH_LEN;
}
+ (int32_t) EDAM_USER_USERNAME_LEN_MIN{
  return EDAMEDAM_USER_USERNAME_LEN_MIN;
}
+ (int32_t) EDAM_USER_USERNAME_LEN_MAX{
  return EDAMEDAM_USER_USERNAME_LEN_MAX;
}
+ (NSString *) EDAM_USER_USERNAME_REGEX{
  return EDAMEDAM_USER_USERNAME_REGEX;
}
+ (int32_t) EDAM_USER_NAME_LEN_MIN{
  return EDAMEDAM_USER_NAME_LEN_MIN;
}
+ (int32_t) EDAM_USER_NAME_LEN_MAX{
  return EDAMEDAM_USER_NAME_LEN_MAX;
}
+ (NSString *) EDAM_USER_NAME_REGEX{
  return EDAMEDAM_USER_NAME_REGEX;
}
+ (int32_t) EDAM_TAG_NAME_LEN_MIN{
  return EDAMEDAM_TAG_NAME_LEN_MIN;
}
+ (int32_t) EDAM_TAG_NAME_LEN_MAX{
  return EDAMEDAM_TAG_NAME_LEN_MAX;
}
+ (NSString *) EDAM_TAG_NAME_REGEX{
  return EDAMEDAM_TAG_NAME_REGEX;
}
+ (int32_t) EDAM_NOTE_TITLE_LEN_MIN{
  return EDAMEDAM_NOTE_TITLE_LEN_MIN;
}
+ (int32_t) EDAM_NOTE_TITLE_LEN_MAX{
  return EDAMEDAM_NOTE_TITLE_LEN_MAX;
}
+ (NSString *) EDAM_NOTE_TITLE_REGEX{
  return EDAMEDAM_NOTE_TITLE_REGEX;
}
+ (int32_t) EDAM_NOTE_CONTENT_LEN_MIN{
  return EDAMEDAM_NOTE_CONTENT_LEN_MIN;
}
+ (int32_t) EDAM_NOTE_CONTENT_LEN_MAX{
  return EDAMEDAM_NOTE_CONTENT_LEN_MAX;
}
+ (int32_t) EDAM_APPLICATIONDATA_NAME_LEN_MIN{
  return EDAMEDAM_APPLICATIONDATA_NAME_LEN_MIN;
}
+ (int32_t) EDAM_APPLICATIONDATA_NAME_LEN_MAX{
  return EDAMEDAM_APPLICATIONDATA_NAME_LEN_MAX;
}
+ (int32_t) EDAM_APPLICATIONDATA_VALUE_LEN_MIN{
  return EDAMEDAM_APPLICATIONDATA_VALUE_LEN_MIN;
}
+ (int32_t) EDAM_APPLICATIONDATA_VALUE_LEN_MAX{
  return EDAMEDAM_APPLICATIONDATA_VALUE_LEN_MAX;
}
+ (int32_t) EDAM_APPLICATIONDATA_ENTRY_LEN_MAX{
  return EDAMEDAM_APPLICATIONDATA_ENTRY_LEN_MAX;
}
+ (NSString *) EDAM_APPLICATIONDATA_NAME_REGEX{
  return EDAMEDAM_APPLICATIONDATA_NAME_REGEX;
}
+ (NSString *) EDAM_APPLICATIONDATA_VALUE_REGEX{
  return EDAMEDAM_APPLICATIONDATA_VALUE_REGEX;
}
+ (int32_t) EDAM_NOTEBOOK_NAME_LEN_MIN{
  return EDAMEDAM_NOTEBOOK_NAME_LEN_MIN;
}
+ (int32_t) EDAM_NOTEBOOK_NAME_LEN_MAX{
  return EDAMEDAM_NOTEBOOK_NAME_LEN_MAX;
}
+ (NSString *) EDAM_NOTEBOOK_NAME_REGEX{
  return EDAMEDAM_NOTEBOOK_NAME_REGEX;
}
+ (int32_t) EDAM_NOTEBOOK_STACK_LEN_MIN{
  return EDAMEDAM_NOTEBOOK_STACK_LEN_MIN;
}
+ (int32_t) EDAM_NOTEBOOK_STACK_LEN_MAX{
  return EDAMEDAM_NOTEBOOK_STACK_LEN_MAX;
}
+ (NSString *) EDAM_NOTEBOOK_STACK_REGEX{
  return EDAMEDAM_NOTEBOOK_STACK_REGEX;
}
+ (int32_t) EDAM_PUBLISHING_URI_LEN_MIN{
  return EDAMEDAM_PUBLISHING_URI_LEN_MIN;
}
+ (int32_t) EDAM_PUBLISHING_URI_LEN_MAX{
  return EDAMEDAM_PUBLISHING_URI_LEN_MAX;
}
+ (NSString *) EDAM_PUBLISHING_URI_REGEX{
  return EDAMEDAM_PUBLISHING_URI_REGEX;
}
+ (NSMutableSet *) EDAM_PUBLISHING_URI_PROHIBITED{
  return EDAMEDAM_PUBLISHING_URI_PROHIBITED;
}
+ (int32_t) EDAM_PUBLISHING_DESCRIPTION_LEN_MIN{
  return EDAMEDAM_PUBLISHING_DESCRIPTION_LEN_MIN;
}
+ (int32_t) EDAM_PUBLISHING_DESCRIPTION_LEN_MAX{
  return EDAMEDAM_PUBLISHING_DESCRIPTION_LEN_MAX;
}
+ (NSString *) EDAM_PUBLISHING_DESCRIPTION_REGEX{
  return EDAMEDAM_PUBLISHING_DESCRIPTION_REGEX;
}
+ (int32_t) EDAM_SAVED_SEARCH_NAME_LEN_MIN{
  return EDAMEDAM_SAVED_SEARCH_NAME_LEN_MIN;
}
+ (int32_t) EDAM_SAVED_SEARCH_NAME_LEN_MAX{
  return EDAMEDAM_SAVED_SEARCH_NAME_LEN_MAX;
}
+ (NSString *) EDAM_SAVED_SEARCH_NAME_REGEX{
  return EDAMEDAM_SAVED_SEARCH_NAME_REGEX;
}
+ (int32_t) EDAM_USER_PASSWORD_LEN_MIN{
  return EDAMEDAM_USER_PASSWORD_LEN_MIN;
}
+ (int32_t) EDAM_USER_PASSWORD_LEN_MAX{
  return EDAMEDAM_USER_PASSWORD_LEN_MAX;
}
+ (NSString *) EDAM_USER_PASSWORD_REGEX{
  return EDAMEDAM_USER_PASSWORD_REGEX;
}
+ (int32_t) EDAM_BUSINESS_URI_LEN_MAX{
  return EDAMEDAM_BUSINESS_URI_LEN_MAX;
}
+ (int32_t) EDAM_NOTE_TAGS_MAX{
  return EDAMEDAM_NOTE_TAGS_MAX;
}
+ (int32_t) EDAM_NOTE_RESOURCES_MAX{
  return EDAMEDAM_NOTE_RESOURCES_MAX;
}
+ (int32_t) EDAM_USER_TAGS_MAX{
  return EDAMEDAM_USER_TAGS_MAX;
}
+ (int32_t) EDAM_BUSINESS_TAGS_MAX{
  return EDAMEDAM_BUSINESS_TAGS_MAX;
}
+ (int32_t) EDAM_USER_SAVED_SEARCHES_MAX{
  return EDAMEDAM_USER_SAVED_SEARCHES_MAX;
}
+ (int32_t) EDAM_USER_NOTES_MAX{
  return EDAMEDAM_USER_NOTES_MAX;
}
+ (int32_t) EDAM_BUSINESS_NOTES_MAX{
  return EDAMEDAM_BUSINESS_NOTES_MAX;
}
+ (int32_t) EDAM_USER_NOTEBOOKS_MAX{
  return EDAMEDAM_USER_NOTEBOOKS_MAX;
}
+ (int32_t) EDAM_BUSINESS_NOTEBOOKS_MAX{
  return EDAMEDAM_BUSINESS_NOTEBOOKS_MAX;
}
+ (int32_t) EDAM_USER_RECENT_MAILED_ADDRESSES_MAX{
  return EDAMEDAM_USER_RECENT_MAILED_ADDRESSES_MAX;
}
+ (int32_t) EDAM_USER_MAIL_LIMIT_DAILY_FREE{
  return EDAMEDAM_USER_MAIL_LIMIT_DAILY_FREE;
}
+ (int32_t) EDAM_USER_MAIL_LIMIT_DAILY_PREMIUM{
  return EDAMEDAM_USER_MAIL_LIMIT_DAILY_PREMIUM;
}
+ (int64_t) EDAM_USER_UPLOAD_LIMIT_FREE{
  return EDAMEDAM_USER_UPLOAD_LIMIT_FREE;
}
+ (int64_t) EDAM_USER_UPLOAD_LIMIT_PREMIUM{
  return EDAMEDAM_USER_UPLOAD_LIMIT_PREMIUM;
}
+ (int64_t) EDAM_USER_UPLOAD_LIMIT_BUSINESS{
  return EDAMEDAM_USER_UPLOAD_LIMIT_BUSINESS;
}
+ (int32_t) EDAM_NOTE_SIZE_MAX_FREE{
  return EDAMEDAM_NOTE_SIZE_MAX_FREE;
}
+ (int32_t) EDAM_NOTE_SIZE_MAX_PREMIUM{
  return EDAMEDAM_NOTE_SIZE_MAX_PREMIUM;
}
+ (int32_t) EDAM_RESOURCE_SIZE_MAX_FREE{
  return EDAMEDAM_RESOURCE_SIZE_MAX_FREE;
}
+ (int32_t) EDAM_RESOURCE_SIZE_MAX_PREMIUM{
  return EDAMEDAM_RESOURCE_SIZE_MAX_PREMIUM;
}
+ (int32_t) EDAM_USER_LINKED_NOTEBOOK_MAX{
  return EDAMEDAM_USER_LINKED_NOTEBOOK_MAX;
}
+ (int32_t) EDAM_NOTEBOOK_SHARED_NOTEBOOK_MAX{
  return EDAMEDAM_NOTEBOOK_SHARED_NOTEBOOK_MAX;
}
+ (int32_t) EDAM_NOTE_CONTENT_CLASS_LEN_MIN{
  return EDAMEDAM_NOTE_CONTENT_CLASS_LEN_MIN;
}
+ (int32_t) EDAM_NOTE_CONTENT_CLASS_LEN_MAX{
  return EDAMEDAM_NOTE_CONTENT_CLASS_LEN_MAX;
}
+ (NSString *) EDAM_HELLO_APP_CONTENT_CLASS_PREFIX{
  return EDAMEDAM_HELLO_APP_CONTENT_CLASS_PREFIX;
}
+ (NSString *) EDAM_FOOD_APP_CONTENT_CLASS_PREFIX{
  return EDAMEDAM_FOOD_APP_CONTENT_CLASS_PREFIX;
}
+ (NSString *) EDAM_NOTE_CONTENT_CLASS_REGEX{
  return EDAMEDAM_NOTE_CONTENT_CLASS_REGEX;
}
+ (NSString *) EDAM_CONTENT_CLASS_HELLO_ENCOUNTER{
  return EDAMEDAM_CONTENT_CLASS_HELLO_ENCOUNTER;
}
+ (NSString *) EDAM_CONTENT_CLASS_HELLO_PROFILE{
  return EDAMEDAM_CONTENT_CLASS_HELLO_PROFILE;
}
+ (NSString *) EDAM_CONTENT_CLASS_FOOD_MEAL{
  return EDAMEDAM_CONTENT_CLASS_FOOD_MEAL;
}
+ (NSString *) EDAM_CONTENT_CLASS_SKITCH{
  return EDAMEDAM_CONTENT_CLASS_SKITCH;
}
+ (NSString *) EDAM_CONTENT_CLASS_PENULTIMATE{
  return EDAMEDAM_CONTENT_CLASS_PENULTIMATE;
}
+ (int32_t) EDAM_RELATED_PLAINTEXT_LEN_MIN{
  return EDAMEDAM_RELATED_PLAINTEXT_LEN_MIN;
}
+ (int32_t) EDAM_RELATED_PLAINTEXT_LEN_MAX{
  return EDAMEDAM_RELATED_PLAINTEXT_LEN_MAX;
}
+ (int32_t) EDAM_RELATED_MAX_NOTES{
  return EDAMEDAM_RELATED_MAX_NOTES;
}
+ (int32_t) EDAM_RELATED_MAX_NOTEBOOKS{
  return EDAMEDAM_RELATED_MAX_NOTEBOOKS;
}
+ (int32_t) EDAM_RELATED_MAX_TAGS{
  return EDAMEDAM_RELATED_MAX_TAGS;
}
+ (int32_t) EDAM_BUSINESS_NOTEBOOK_DESCRIPTION_LEN_MIN{
  return EDAMEDAM_BUSINESS_NOTEBOOK_DESCRIPTION_LEN_MIN;
}
+ (int32_t) EDAM_BUSINESS_NOTEBOOK_DESCRIPTION_LEN_MAX{
  return EDAMEDAM_BUSINESS_NOTEBOOK_DESCRIPTION_LEN_MAX;
}
+ (NSString *) EDAM_BUSINESS_NOTEBOOK_DESCRIPTION_REGEX{
  return EDAMEDAM_BUSINESS_NOTEBOOK_DESCRIPTION_REGEX;
}
+ (int32_t) EDAM_PREFERENCE_NAME_LEN_MIN{
  return EDAMEDAM_PREFERENCE_NAME_LEN_MIN;
}
+ (int32_t) EDAM_PREFERENCE_NAME_LEN_MAX{
  return EDAMEDAM_PREFERENCE_NAME_LEN_MAX;
}
+ (int32_t) EDAM_PREFERENCE_VALUE_LEN_MIN{
  return EDAMEDAM_PREFERENCE_VALUE_LEN_MIN;
}
+ (int32_t) EDAM_PREFERENCE_VALUE_LEN_MAX{
  return EDAMEDAM_PREFERENCE_VALUE_LEN_MAX;
}
+ (int32_t) EDAM_MAX_PREFERENCES{
  return EDAMEDAM_MAX_PREFERENCES;
}
+ (int32_t) EDAM_MAX_VALUES_PER_PREFERENCE{
  return EDAMEDAM_MAX_VALUES_PER_PREFERENCE;
}
+ (NSString *) EDAM_PREFERENCE_NAME_REGEX{
  return EDAMEDAM_PREFERENCE_NAME_REGEX;
}
+ (NSString *) EDAM_PREFERENCE_VALUE_REGEX{
  return EDAMEDAM_PREFERENCE_VALUE_REGEX;
}
+ (int32_t) EDAM_DEVICE_ID_LEN_MAX{
  return EDAMEDAM_DEVICE_ID_LEN_MAX;
}
+ (NSString *) EDAM_DEVICE_ID_REGEX{
  return EDAMEDAM_DEVICE_ID_REGEX;
}
+ (int32_t) EDAM_DEVICE_DESCRIPTION_LEN_MAX{
  return EDAMEDAM_DEVICE_DESCRIPTION_LEN_MAX;
}
+ (NSString *) EDAM_DEVICE_DESCRIPTION_REGEX{
  return EDAMEDAM_DEVICE_DESCRIPTION_REGEX;
}
@end
