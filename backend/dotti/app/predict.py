import sys
from google.cloud import automl_v1beta1
# from automl_v1beta1.proto import service_pb2


# 'content' is base-64-encoded image data.
def get_prediction(client, content):
  project_id, model_id = "840748367646", "IOD4212411564940066816"
  name = 'projects/{}/locations/us-central1/models/{}'.format(project_id, model_id)
  payload = {'image': {'image_bytes': content }}
  params = {}
  request = client.predict(name=name, payload=payload, params=params)
  return request  # waits till request is returned

if __name__ == '__main__':
  file_path = sys.argv[1]
  project_id = sys.argv[2]
  model_id = sys.argv[3]
  prediction_client = automl_v1beta1.PredictionServiceClient()

  with open(file_path, 'rb') as ff:
    content = ff.read()

  print(get_prediction(prediction_client, content).payload)