# S3 website with CloudFront

Terraform template for a S3 website with a CloudFront distribution.

Features:
- HTTPS
- CloudFront caching
- Redirects to https
- Security headers set: [SecurityHeadersPolicy](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/using-managed-response-headers-policies.html#managed-response-headers-policies-security)
- Redirect from www.example.com to example.com
- Bucket object not directly accessible

This Terraform template uses two CloudFront distributions. One is used for the main domain and the other is used for the domain to be redirected to the main domain. The redirect is done with S3 website redirect requests option. 

## Prevent direct S3 object access

To prevent the direct access to the S3 bucket objects I added a referer header condition to the S3 bukcet policy.
The S3 bucket policy below makes sure only GET requests are allowed if the `Referer` is present.
CloudFront is set up to always send the `Referer` header with the `SECRET_STRING`. This allows CloudFront to access the objects in your S3 bucket.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "s3:GetObject",
      "Resource": [
        "arn:aws:s3:::example.com/*",
        "arn:aws:s3:::example.com"
      ],
      "Condition": {
        "StringLike": {
          "aws:Referer": "SECRET_STRING"
        }
      }
    }
  ]
}
```

# Github action deployment
In this example I will show you how to deploy to the S3 bucket and invalidate the cache from a GitHub Action.

To make the example below work you have to set the following [secrets in GitHub](https://docs.github.com/en/actions/security-guides/encrypted-secrets):
- `S3_BUCKET_NAME` 
- `CLOUDFRONT_DISTRIBUTION_ID`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

**Important**: **DO NOT** use your root or full admin access AWS access key and secret. 

These two GitHub workflow steps will deploy the `public/` to S3 and invalidates the CloudFront cache for all paths.
```yaml
  - name: Deploy to S3
    run: aws s3 sync public/ s3://${{ secrets.S3_BUCKET_NAME }}/ --delete --region INSERT_YOUR_AWS_REGION_HERE
    env:
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
  - name: Invalidate CloudFront cache
    run: aws cloudfront create-invalidation --distribution-id=${{ secrets.CLOUDFRONT_DISTRIBUTION_ID }} --paths='/*' --region INSERT_YOUR_AWS_REGION_HERE
    env:
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

### IAM for deployment

Do not use your root or admin access AWS key and secret for the deployment from a GitHub action.

Instead, create a new user specifically for the GitHub deployment and give it these permissions. 

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Hugo deployment",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:PutBucketPolicy",
                "s3:ListBucket",
                "s3:DeleteObject",
                "s3:PutObjectAcl",
                "cloudfront:CreateInvalidation",
                "s3:GetBucketPolicy"
            ],
            "Resource": [
                "arn:aws:cloudfront::ACCOUNTID:distribution/DISTRIBUTIONID",
                "arn:aws:s3:::example.com",
                "arn:aws:s3:::example.com/*"
            ]
        }
    ]
}
```

### Full example

Below you will find an example with a complete GitHub workflow file. This workflow builds the static website with [Hugo](https://gohugo.io/), deploys to S3 and invalidates the cache in CloudFront.

```yaml
name: Build and deploy

on:
  push:
    branches:
      - main

jobs:
  build:
    name: Build and deploy
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v1
      - name: Install Hugo
        run: |
          wget https://github.com/gohugoio/hugo/releases/download/v0.91.2/${{ env.HUGO_FILE_NAME }}
          tar -xvzf ${{ env.HUGO_FILE_NAME }} hugo
          mv hugo $HOME/hugo
        env:
          HUGO_FILE_NAME: "hugo_extended_0.91.2_Linux-64bit.tar.gz"
      - name: Hugo Build
        run: $HOME/hugo --verbose
      - name: Deploy to S3
        run: aws s3 sync public/ s3://${{ secrets.S3_BUCKET_NAME }}/ --delete --region INSERT_YOUR_AWS_REGION_HERE
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      - name: Invalidate CloudFront cache
        run: aws cloudfront create-invalidation --distribution-id=${{ secrets.CLOUDFRONT_DISTRIBUTION_ID }} --paths='/*' --region INSERT_YOUR_AWS_REGION_HERE
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```