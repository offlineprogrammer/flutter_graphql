
import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import {
  AmplifyGraphqlApi,
  AmplifyGraphqlDefinition
} from '@aws-amplify/graphql-api-construct';

export class CdkBackendStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const amplifyApi = new AmplifyGraphqlApi(this, 'AmplifyCdkGraphQlApi', {
      definition: AmplifyGraphqlDefinition.fromFiles('../graphql/schema.graphql'),
      authorizationModes: {
        defaultAuthorizationMode: 'API_KEY',
        apiKeyConfig: {
          expires: cdk.Duration.days(30)
        }
      }
    });
  }
}