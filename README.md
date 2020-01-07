# Printbeat
Printbeat is an e-commerce iOS application where you can purchase canvas art. 
- Two apps in total: User App and Admin App.
- Language: Swift + Node.js backend.
- Technologies/APIs: Google Firestore, Google Cloud Functions (Node.js), Stripe, SendGrid.

![main_demo](Demo/main.gif)

# Customer App
Login and sign up are implemented using Google Firebase Authentication.

![1](https://user-images.githubusercontent.com/22768968/71924092-274aba00-3143-11ea-9ca1-464292cb5530.png)

![2](https://user-images.githubusercontent.com/22768968/71923920-de930100-3142-11ea-8fec-1bc16bb05166.png)
- Stripe Payment Intents API is used for payment processing (meets the new Strong Customer Authentication requirements in the European Economic Area). All the requests and logic related to recording a purchase in the Printbeat database take place in the backend (Node.js/Google Cloud Functions). 
- Also, before charging a customer's card, total amount is recalculated in the backend for correctness and protection from fraud. 
- Stripe Webhooks functionality is used to trigger a function that records a purchase in the cloud database after a successful charge.

![3](https://user-images.githubusercontent.com/22768968/71924833-a391cd00-3144-11ea-867c-8e6ba412813b.png)

![4](https://user-images.githubusercontent.com/22768968/71925100-2450c900-3145-11ea-80c8-1864ee5c1421.png)

![5](https://user-images.githubusercontent.com/22768968/71925259-7e518e80-3145-11ea-82d1-135d445880b7.png)

# Admin App

![6](https://user-images.githubusercontent.com/22768968/71925463-f4ee8c00-3145-11ea-9684-10e2e1c8c9fd.png)

![7](https://user-images.githubusercontent.com/22768968/71925559-2b2c0b80-3146-11ea-8666-a64383cb5b2a.png)

![8](https://user-images.githubusercontent.com/22768968/71925596-47c84380-3146-11ea-920b-6e7c6c129665.png)

![9](https://user-images.githubusercontent.com/22768968/71925676-6e867a00-3146-11ea-88f6-e093ba4cbade.gif)

![10](https://user-images.githubusercontent.com/22768968/71925719-8958ee80-3146-11ea-9c30-19bc7982ffc7.gif)

![11](https://user-images.githubusercontent.com/22768968/71925757-9c6bbe80-3146-11ea-8662-a8f645621146.png)
