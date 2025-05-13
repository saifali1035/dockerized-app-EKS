import express from 'express';
import AWS from 'aws-sdk';
import cors from 'cors';

const app = express();
const port = 8080;

// Enable CORS
app.use(cors());

// AWS Config
AWS.config.update({
  region: 'ap-south-1'
});

const dynamoDB = new AWS.DynamoDB.DocumentClient();

app.get('/testdb', async (req, res) => {
  try {
    const data = await dynamoDB.scan({ TableName: 'my-table' }).promise();
    res.json({ success: true, data });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: 'Failed to fetch data from DynamoDB' });
  }
});

app.listen(port, () => {
  console.log(`✅ Backend app running on port ${port}`);
});
