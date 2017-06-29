# k5env-script

```
Script to retrieve an authentication token and configure environment vars for API endpoints and Openstack python
clients etc. Reads credentials from files named k5creds_CONTRACT-USER.txt - files are formatted as follows:

CONTRACT=YourContractID
USER=YourUserName
PW=YourPasword
REGION=K5Region
  
If no k5creds files exist you will be prompted to enter details after which a file will be saved for future use.
API environment variables will only be set if required. By default API endpoint variables will include the API
version and project id if returned, if you wish to use the truncated endpoint variable as seen in the examples
in the documentation then edit the script as change EPFULL=true to EPFULL=false.

The script should be dot sourced when called:

$ . ./set-k5env.sh

Choose credentials to use:

1)       uHyysKjl-my.user
2)       PkWwjNsx-auser
3)       OqhYddfT-username
N)       Enter new credentials

[Enter 1 - 3 or N]:

Enter all or part of your project name (leave blank to see all): cto
1)       AT_CTO_PS
2)       UK_HIT_CTO
3)       UK_HIT_CTO_Labs
4)       UK_HIT_CTO_LEMP_Test

[Enter 1 - 4]: 2

Project Name: UK_HIT_CTO_Labs
Project ID:   fdfce7c87ec6a74287946c46a060ba4a
OS_AUTH_TOKEN: db45caef97074d5abfe0b66bd63b7845
Setting Endpoints...
APPMANAGEMENT=https://applicationmanagement.uk-1.cloud.global.fujitsu.com
AUTOSCALE=https://autoscale.uk-1.cloud.global.fujitsu.com/autoscale_schedulers
BLOCKSTORAGE=https://blockstorage.uk-1.cloud.global.fujitsu.com/v1/fdfce7c87ec6a74287946c46a060ba4a
BLOCKSTORAGEV2=https://blockstorage.uk-1.cloud.global.fujitsu.com/v2/fdfce7c87ec6a74287946c46a060ba4a
CERTIFICATE=https://certificate.uk-1.cloud.global.fujitsu.com/v1
COMPUTE_B=https://compute-b.uk-1.cloud.global.fujitsu.com
COMPUTE=https://compute.uk-1.cloud.global.fujitsu.com/v2/fdfce7c87ec6a74287946c46a060ba4a
COMPUTE_W=https://compute-w.uk-1.cloud.global.fujitsu.com
DATABASE=https://database.uk-1.cloud.global.fujitsu.com/v1.0/fdfce7c87ec6a74287946c46a060ba4a
GLOBAL_IDENTITY=https://identity.gls.cloud.global.fujitsu.com/v3
IDENTITY=https://identity.uk-1.cloud.global.fujitsu.com/v2.0
IDENTITYV3=https://identity.uk-1.cloud.global.fujitsu.com/v3
IMAGE=https://image.uk-1.cloud.global.fujitsu.com
IMPORT_EXPORT=https://import-export.uk-1.cloud.global.fujitsu.com
KEYMANAGEMENT=https://keymanagement.uk-1.cloud.global.fujitsu.com/v1
LOADBALANCING=https://loadbalancing.uk-1.cloud.global.fujitsu.com
NETWORKING_EX=https://networking-ex.uk-1.cloud.global.fujitsu.com
NETWORKING=https://networking.uk-1.cloud.global.fujitsu.com
OBJECTSTORAGE=https://objectstorage.uk-1.cloud.global.fujitsu.com/v1/AUTH_fdfce7c87ec6a74287946c46a060ba4a
ORCHESTRATION=https://orchestration.uk-1.cloud.global.fujitsu.com/v1/fdfce7c87ec6a74287946c46a060ba4a
QUEUE=https://queue.uk-1.cloud.global.fujitsu.com
ROLEMANAGEMENT=https://rolemanagement.uk-1.cloud.global.fujitsu.com/v1
SOFTWARE=https://software.uk-1.cloud.global.fujitsu.com/v1.0
TELEMETRY=https://telemetry.uk-1.cloud.global.fujitsu.com
VMIMPORT=https://vmimport.uk-1.cloud.global.fujitsu.com
