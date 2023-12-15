
import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import { AmplifyData, AmplifyDataDefinition } from '@aws-amplify/data-construct';


export class CdkBackendStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    new AmplifyData(this, 'AmplifyCdkData', {
      definition: AmplifyDataDefinition.fromFiles('../graphql/schema.graphql'),
      authorizationModes: {
        defaultAuthorizationMode: 'API_KEY',
        apiKeyConfig: {
          expires: cdk.Duration.days(30)
        }
      }
    });
  }
}