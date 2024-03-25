# Tickers
**Tickers** provides a high level overview of the state of the cryptocurrencies market. 

After launch, the overview screen is presented which provides list of cryptocurrencies, where each of the cells is representing one cryptocurrency, containing information such as **name of the coin**, its **price** and its **24-hour change** in percentages. Data is updated every **5 seconds**, providing users with up-to-date information.

<img src="https://github.com/zeljkolucic/Tickers/assets/70879730/6df4b041-cdf1-4c8b-ab1a-9150e4cca077" alt="drawing" width="250">
<img src="https://github.com/zeljkolucic/Tickers/assets/70879730/661d4b88-4236-48e4-be83-34161b69b668" alt="drawing" width="250">


The application supports both **light** and **dark appearance** as well.


At the top of the screen there is a search bar which enables users to **filter** coins in order to easily find cryptocurrency they're most interested in.

<img src="https://github.com/zeljkolucic/Tickers/assets/70879730/9dd50b1a-58a5-4d35-8ccb-300f84f25e02" alt="drawing" width="250">
<img src="https://github.com/zeljkolucic/Tickers/assets/70879730/e12a32ee-f949-4871-bc45-f173d358e699" alt="drawing" width="250">


When data is being loaded, a **loading indicator** is presented for a better user experience.

<img src="https://github.com/zeljkolucic/Tickers/assets/70879730/e851dfdd-a8bc-40eb-92cc-3c9c19911a6c" alt="drawing" width="250">
<img src="https://github.com/zeljkolucic/Tickers/assets/70879730/b51b28e3-53e8-49db-96c5-9cf2003e544c" alt="drawing" width="250">


Whenever a network connection is lost, a friendly error message is presented at the top of the screen, and whenever the connection is restored, data is being fetched again and continues to be updated each 5 seconds.

<img src="https://github.com/zeljkolucic/Tickers/assets/70879730/c36c710e-2148-47c2-b942-2bdc320d09a0" alt="drawing" width="250">
<img src="https://github.com/zeljkolucic/Tickers/assets/70879730/d290921d-23e3-4519-b879-9472e9d2d9e3" alt="drawing" width="250">



## Technical Side of Things
**Tickers** is a native iOS application written in **Swift** programming language using **SwiftUI** framework. It is written as a modular monolith, with clear separation of concerns, following **Test-Driven Development (TDD)**.

Since the application has a requirement of updating the data every 5 seconds, **Functional Reactive Paradigm (FRP)** seemed to be a good approach. SwiftUI with Combine handled frequent UI updates effortlessly.

Architecture that has been implemented is a variation of CLEAN architecture, with **Model-View-ViewModel (MVVM)** being implemented as the UI architectural design pattern. The Main component creates the `TickersListView` and `TickersViewModel` as its only dependency, whereas `TickersViewModel` has references to `TickersRepository` and `Reachability`. 
`TickerRepository` is a protocol, an abstraction of `RemoteTickerRepository` which has a reference to `HTTPClient` and its responsibility is to fetch data from the API. 
> However, the API model of `Ticker` named `RemoteTicker` has multiple properties which are not needed for the domain of the application, and therefore `RemoteTickerRepository` maps `RemoteTicker` objects to domain type `Ticker`.

`URLSessionHTTPClient` belongs to the `Infrastructure` layer of the application, and represents an implementation of `HTTPClient` protocol which fetches the data from the given URL using `URLSession`. Since the `URLSessionHTTPClient` is hidden behind an `HTTPClient` protocol, the rest of the collaborators do not know about the implementation, and therefore frameworks like **Alamofire** or **Moya** could be used instead.

<img src="https://github.com/zeljkolucic/Tickers/assets/70879730/0d452e6d-c69d-49ca-b23b-260faf517a55" alt="drawing">

## Unit Tests
`URLSessionHTTPClient` and `RemoteTickerRepository` classes have been fully covered with unit tests, gathering coverage of 94%. Following Test-Driven Development and Behavior Driven Design, each of the test functions consists of three parts – Given, When, Then. Test function have been named in form of – **test_nameOfTheFunctionBeingTested_expectedBehavior**.
