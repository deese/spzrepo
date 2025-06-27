import boto3
import os

cf = boto3.client('cloudfront')
sns = boto3.client('sns')

def lambda_handler(event, context):
    dist_id = os.environ['DISTRIBUTION_ID']
    topic_arn = os.environ['SNS_TOPIC_ARN']

    try:
        config_response = cf.get_distribution_config(Id=dist_id)
        etag = config_response['ETag']
        config = config_response['DistributionConfig']

        config['Enabled'] = False

        cf.update_distribution(
            Id=dist_id,
            IfMatch=etag,
            DistributionConfig=config
        )

        msg = f"✅ CloudFront distribution {dist_id} has been disabled due to budget limit."
        sns.publish(TopicArn=topic_arn, Message=msg, Subject="CloudFront Disabled")

    except Exception as e:
        sns.publish(TopicArn=topic_arn,
                    Message=f"❌ Failed to disable CloudFront distribution {dist_id}: {str(e)}",
                    Subject="CloudFront Disable FAILED")
        raise

    return {
        "statusCode": 200,
        "body": "Notification sent."
    }

