const express = require('express');
const app = express();

const facts = [
  "DevOps is a combination of development and operations.",
  "CI/CD pipelines automate build, test, and deployment stages.",
  "Docker allows apps to run in isolated environments.",
  "Terraform helps manage infrastructure as code.",
  "Ansible uses YAML playbooks to automate server configuration.",
  "Jenkins is a popular open-source CI/CD tool.",
  "DevOps encourages frequent and reliable software releases.",
  "Infrastructure as Code (IaC) enables version control for infrastructure.",
  "Monitoring is essential in every DevOps lifecycle.",
  "DevOps bridges the gap between developers and IT operations."
];

app.get('/', (req, res) => {
  res.send(`<h1>🚀 Welcome to the DevOps Facts API</h1>
            <p>Try <code>/api/fact</code> to get a random DevOps fact!</p>
            <p><strong>New commit deployed successfully!</strong></p>`);
});

app.get('/api/fact', (req, res) => {
  const randomIndex = Math.floor(Math.random() * facts.length);
  res.json({
    fact: facts[randomIndex]
  });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🎉 DevOps Facts API running on http://localhost:${PORT}`);
});
