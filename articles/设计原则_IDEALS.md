## 一、关键点：

对于面向对象的设计，我们遵循**SOLID原则**。对于微服务设计，我们建议开发人员遵循**IDEALS原则**：**接口分离（Interface segregation），可部署性（deployability），事件驱动（event-driven），可用性胜于一致性（Availability over Consistency），松耦合（Loose coupling）和单一责任（single responsibility）**。

- 接口分离：指的是不同类型的客户端（移动应用程序，web应用程序，CLI程序）应该能够通过适合其需求的协议与服务端交互。
- 可部署性：指的是在微服务时代，也就是DevOps时代，开发人员需要在打包、部署和运行微服务方面做出关键的设计决策和技术选择。
- 事件驱动：指的是在任何时候，都应该对服务进行建模，通过异步消息或事件而不是同步调用。
- 可用性胜于一致性：指的是最终用户更看重系统的可用性而不是强一致性，它们对最终一致性也很满意。
- 松耦合：仍然是一个重要的设计问题，涉及传入和传出的耦合。
- 单一责任：是一种思想，它支持对不太大或太细的微服务进行建模，因为他们包含了适当数量的内聚功能。

在2000年，Robert C. Martin编写了面向对象设计的五个原则。Michael Feathers后来将这五个原则的首字母组成了缩略词，也就是SOLID。从那时起，用于OO设计的SOLID原则就在业界被广为人知。这五个原则是：

- 单一责任原则（Single responsibility principle）
- 开闭原则（Open/closed principle）
- 里氏代换原则（Liskov substitution principle）
- 界面分离原则（Interface segregation principle）
- 依赖倒置原则（Dependency inversion principle）

几年前，我在给其他人讲授微服务设计时，一个学生问：“SOLID原则适用于微服务吗”，经过一番思考，我的回答是“部分”。后面的几个月，我发现我一直在寻找微服务的基本设计原则（包含一些缩略词）。为什么这样的问题会如此重要呢？

作为一个行业，我们已经设计和实施基于微服务的解决方案已经超过六年了。在此期间，越来越多的工具、框架、平台和支撑产品围绕微服务建立了一个极其丰富的技术环境。在这种情况下，一个新手微服务开发人员在面对一个微服务项目中许多设计决策和技术选择时会感到迷惑。在这个领域，一组核心原则可以帮助开发人员更好的理解基于微服务的解决方案。

虽然有些SOLID原则适用于微服务，但**面向对象是一种设计范式**，它处理的元素有类、接口和继承等，与一般分布式系统中的元素（特别是微服务）有着根本的区别。

因此，我们提出以下一套微服务设计的核心原则：

- 接口分离（Interface segregation）
- 可部署性（Deployability (is on you)）
- 事件驱动（Event-driven）
- 可用性胜于一致性（Availability over consistency）
- 松耦合（Loose coupling）
- 单一职责（Single responsibility）

这些原则并没有覆盖基于微服务的解决方案的所有设计决策，但他们涉及到创建现代基于服务的系统的关键关注点和成功因素。下面对微服务的“**IDEALS**”的原则进行详细的解释。

## 二、接口分离

最初的接口分离原则是指防止面向对象中类使用“胖”接口。换句话说，就是每种类型的客户端应该有单独的接口，而不是提供一个满足所有客户端需要的所有可能方法的接口。

微服务体系结构风格是面向服务体系结构的一种特殊化，其中接口（即服务契约）的设计一直是最重要的。从21世纪初开始，SOA文档就规定了所有客户端都应该遵守的规范模型和规范模式。然而，自从SOA的旧时代以来，我们处理服务契约设计的方式发生了改变。在微服务时代，同一个服务逻辑通常有许多客户端程序。这就是将接口分离应用于微服务的主要目的。

**实现微服务的接口分离**

微服务接口分离的目标是每种类型的前端都能看到最适合其需求的服务契约。例如，一个移动应用程序系统调用端点，这些端点返回简短的JSON格式数据作为响应。当另一个web应用程序需要返回完整的JSON格式数据作为响应。与此同时，还有一个桌面应用程序调用同一个服务，但需要返回完整的XML格式数据。不同的客户端也可能使用不同的协议。例如，外部的客户端希望使用HTTP来调用gRPC服务。

我们没有试图在所有类型的服务客户机上强加相同的服务契约（使用规范模型），而是通过“分离接口”，以便每种类型的客户机都能看到它需要的服务接口。我们怎么做？一个突出的选择是使用API网关，它可以进行消息格式转换（message format transformation），消息结构转换（message structure transformation），协议桥接（protocol bridging），消息路由（message routing）等。一个流行的替代方案是**BFF（Backend for Frontends）**模式。在这种情况下，我们为每种不同类型的客户机提供了一个API网关，也就是通常说的，为每种客户机提供不同的BFF,如下图所示：

![微服务设计的原则：IDEALS，而不是SOLID](http://image109.360doc.com/DownloadImg/2020/10/1002/204155651_2_2020101002552822)

## 三、可部署性

几乎在整个软件历史上，设计工作都集中在与实现单元（模块）如何组织以及运行时元素如何交互相关的设计决策上。架构策略、设计模式和其他设计策略为在层中组织软件元素、避免过度依赖、为特定类型的组件分配特定的角色或关注点以及软件空间中的其他设计决策提供了指导。对于微服务开发人员来说，有一些关键的设计决策超出了软件元素。

作为开发人员，我们早就意识到将软件正确打包并部署到适当的运行时环境中的重要性。然而，我们从没有像今天的微服务那样关注部署和运行时监控。在这里称为“可部署性”的技术和设计决策领域已经成为微服务成功的关键。主要原因是一个简单的事实，即微服务显著增加了部署单元的数量。

因此，IDEALS中的D代表微服务开发者有责任确保软件及其新版本随时可以部署到环境中供用户使用。总之，可部署性包括：

- 配置运行时基础设施，包括容器、pods、集群、持久性、安全性和网络。
- 微服务的扩缩容，或者将他们从一个运行时环境迁移到另一个运行时环境。
- 加速提交+构建+测试+部署过程
- 减少版本升级时的停机时间
- 同步相关软件的版本更改
- 监控微服务运行状况，以快速识别和修复故障。

**实现良好的可部署性**

自动化是实现高效部署的关键。自动化包括明智的使用工具和技术，这是自微服务出现以来不断看到最大变化的领域。因此，微服务开发人员应该在工具和平台方面寻找新的方向。但总是质疑每一个新选择的好处和挑战。（这里可参考Thoughtworks技术雷达和软件架构与设计趋势报告）

以下是开发人员在任何基于微服务的解决方案中为提高可部署性而应该考虑的策略和技术列表：

- **容器化和容器编排**：容器化的微服务更容易实现跨平台和云提供商进行复制和部署，而编排平台为路由、扩展、复制、负载均衡等提供了共享资源和机制。Docker和Kubernetes是当今容器和容器编排的事实标准。
- **服务网格**：这种工具可以用于流量监控，策略执行，身份验证，RBAC，路由，断路器、消息转换等，以帮助容器编排平台中的服务进行通信。流行的服务网格包括Istio、Linkerd和Consul Connect。
- **API网关**：通过拦截对微服务的调用，API网关产品提供了丰富的功能集，包括消息转换和协议桥接、流量监控、安全控制、路由、缓存、请求限制和API配额以及熔断。这一领域的主要参与者是Ambassador、Kong、Apiman、WSO2 API Manager、Apigee和Amazon API Gateway。
- **无服务器架构**：通过将服务部署到遵循FaaS范式的无服务器平台，可以避免容器编排的复杂性和操作成本。AWS Lambda、Azure函数和Google云函数都是无服务器平台的示例.
- **日志整合工具**：微服务可以轻松的将部署单元的数量增加一个数量级。我们需要工具来整合这些组件的日志输出，以及搜索、分析和生成告警的能力。这个领域流行的工具有Fluentd、Graylog、Splunk和ELK（Elasticsearch、Logstash、Kibana）。
- **链路跟踪工具**：这些工具可用于检测您的微服务，然后生成、收集和可视化运行时跟踪数据，以显示跨服务的调用。它可以帮助您发现性能问题。跟踪工具的例子有Zipkin, Jaeger, and AWS X-Ray，OpenTraceing。
- **DevOps**：当开发人员和运维人员可以进行更紧密的沟通和协作时，微服务的工作会更加容易，从基础设施配置到事件处理。
- **蓝绿部署和金丝雀发布**：这些部署策略允许在发布新版本的微服务时实现零或接近零的停机时间，并在出现问题时进行快速切换。
- **基础设施即代码**：这种做法使得构建-部署周期中的交互更少，从而变得更快，更不容易出错，更易于审计。
- **持续交付**：这是缩短从提交到部署间隔并保持代码质量的必要实践。传统的CICD工具有Jenkins、Gitlab CI/CD、Bamboo、GoCD、CircleCI和Spinnaker。最近，Weaveworks和Flux等GitOps工具被添加到这个领域，将CD和IaC结合起来。
- **配置管理**：将配置属性存储在微服务部署单元之外，并且易于管理。

## 四、事件驱动

微服务架构风格用于创建后端服务，这些服务通常使用以下三种类型的方式进行调用：

- HTTP调用（REST服务）
- 使用特定于平台的组件技术进行类RPC调用，如gRPC或GraphQL
- 通过消息中间件处理异步消息

前两个通常是同步的，HTTP调用也是最常见的方式。通常，服务需要调用其他服务进行组合，太多时候，组合中的服务调用是同步的。如果异步，需要连接和接收Queue/Topic里的消息，那么我们将创建一个事件驱动的体系结构。（我们可以讨论消息驱动和事件驱动的区别，但都可以表示网络上的异步通信，使用消息中间件产品（Apache Kafka、RabbitMQ和Amazon SNS）提供的Queue和Topic）

事件驱动体系结构的一个重要好处是提高了可伸缩性和吞吐量。这是因为：消息发送者在等待响应时不会被阻塞，并且同一个消息/事件可以由多个接收者以发布-订阅的方式并行使用。

**事件驱动的微服务**

IDEALS中的E就表示使用事件驱动对微服务进行建模。因为他们更能满足当今软件解决方案的可伸缩性和性能要求，这种设计还促进了松耦合，因为消息发送方和接收方——微服务——是对立的，彼此不了解。可靠性也得到了提升，因为这个设计可以处理微服务的临时中断，当微服务恢复后可以处理排队中的消息。

但事件驱动的微服务，也称为反应式微服务，也会带来挑战，比如异步处理和并行执行，可能需要同步点和相关标识符。设计需要考虑错误和丢失的消息——校正事件和撤销数据更改的机制（如Saga模式）通常是必须的。对于事件驱动体系结构带来的面向用户的事务，应仔细考虑用户体验，以使最终用户了解进度和事故。

## 五、可用性胜于一致性

CAP理论本质上给了我们两个选择：可用性或者一致性。我们看到业界为了让我们选择可用性而付出了巨大努力，从而最终实现一致性。原因很简单：今天的最终用户不会容忍服务不可用。假如一个网络商店，如果我们在浏览产品时显示的库存量和购买时更新的实际库存量之间强制执行强一致，那么数据变更将会带来巨大的开销，如何任何更新库存的服务暂时无法访问，那么页面无法显示库存信息，结账将停止服务。相反，如果选择可用性，用户浏览产品时显示的库存量和购买时更新的实际库存量之间会有偶尔的不一致。当用户在下单买时，然后再去查询真实的库存量，如果没有库存，再提示用户没有库存。从用户的角度来看，这个场景比由于系统要实现强一致而让整个系统不可用或超级慢对所有用户来说要好很多。

有些业务操作确实需要很强的一致性。然而，正如Pat Helland指出，当你面对你是想要正确?还是想要现在?的问题时，人们通常想要的是现在而不是正确的答案时，就需要考虑强一致。

**最终一致性的可用性**

对于微服务来说，保证可用性选择的主要策略是**数据复制**。可以采用不同的设计模式，有时可以组合使用。

- **服务数据复制模式**：当微服务需要访问属于其他应用程序的数据（而API调用不适合获取数据）时，使用此基本模式。我们创建该数据的副本，并使其随时可供微服务使用。该解决方案还需要一种数据同步机制（如ETL工具/程序、发布-订阅消息传递、物化视图），该机制将定期或基于触发器使副本与主数据库保持一致。
- **命令查询责任分离（CQRS）模式**：这里我们将更改数据（Command）的操作设计与实现和只读数据（Query）的操作分开。CQRS通常建立在服务数据复制的基础上，用于提高查询的效率。
- **事件源（Event Source）模式**：我们不在数据库中存储对象的当前状态，而是存储影响该对象的仅附加的、不可变的事件序列。当前状态是通过回放事件获得，这样做是为了提供数据的“查询视图”。因此，事件源通常建立在CQRS设计的基础上。

我们经常使用的CQRS模式通常如下图所示：一个可以更改数据的HTTP请求由后台一个REST服务处理，该服务可以操作一个集中式的Oracle数据库。其他只读的HTTP请求转到另一个后台服务，该服务可以从基于文本的Elasticsearch数据存储中获取数据。一个Spring Batch Kubernetes cron任务定期将在Oracle数据库中的变更同步到ES中，这个设计使用两个数据存储之间的最终一致性。即使Oracle DB和cron任务不起作用，查询服务也是可用的。

![微服务设计的原则：IDEALS，而不是SOLID](http://image109.360doc.com/DownloadImg/2020/10/1002/204155651_3_20201010025528225)

## 六、松耦合

在软件工程中，耦合是指两个软件元素之间相互依赖的程度。对于基于服务的系统来说，**传入耦合**是指服务用户如何与服务交互。我们知道这种交互应该通过**服务契约**来实现，并且该服务契约不应该与实现细节和特定技术紧密结合。服务是可以由不同程序调用的分布式组件。有时候，服务提供方不知道所有服务用户在哪里（公共API服务通常就是这样）。因此，服务契约应该避免变更。如何服务契约与服务逻辑或技术紧密耦合，那么当逻辑或技术需要演化时，它也需要同时发生变化。

服务通常需要与其他服务或其他类型的组件交互，从而产生**传出耦合**。这种交互建立了直接影响**服务自治**的运行时依赖关系。如果一个服务的自治性较低，它的行为就不那么可预测：**最好的情况就是，该服务将与他需要调用的最慢的，最不可靠的和最不可用的组件一样快速、可靠和可用**。

**微服务的松耦合策略**

IDEALS中的L表示要关注服务及微服务的耦合。可以使用并组合多种策略来改进**传入和传出**的松散耦合。这些策略包括：

- **点对点和发布-订阅（Point-to-point and Publish-subscribe）**：这种通过消息传递的模式改进了耦合性，因为发送方和接收方彼此不知道对方。响应式微服务（如Kafka消费方）的契约将成为消息队列的名称和消息的结构体。
- **API网关和BFF**：这些解决方案规定了一个中间组件，该组件处理服务契约与客户端需要的消息格式和协议之间的差异，从而有助于分离他们。
- **契约优先设计（Contract-first design）**：通过设计与任何现有代码相关的契约，从而避免创建与技术和实现紧密耦合的api。
- **超媒体（Hypermedia）**：对于REST服务，超媒体帮助前端更加独立于服务端点。
- **Facade和Adapter/Wrapper模式**：这些GoF模式的变体在微服务架构中可以规定内部的组件和服务，可以防止在微服务实现中传播不良的耦合性。
- **每个微服务一个数据库模式**：该模式使得微服务不仅获得了自治性，而且避免了与数据库共享带来的直接耦合。

## 七、单一职责

最初的单一职责原则（ Single Responsibility Principle，SRP）是关于在OO类中具有内聚功能。在一个类中拥有多个职责自然会导致紧耦合，并导致脆弱的设计，在变更时会发生意想不到的结果。SRP这个想法很简单，也很容易理解，但要用好并不容易。

单一职责的概念可以扩展到微服务中服务的内聚性。微服务体系结构风格部署单元应该包含一个服务或几个内聚服务。如果一个微服务包含太多的职责，也就是说，有太多不太具有内聚力的服务，那么它就可能会承受一个巨大的痛苦。膨胀的微服务在功能和技术栈方面变得更难发展。而且，持续交付将会变得繁重，因为他们将会使许多开发人员在同一个部署单元开发不同的内容。

另一方面，如果微服务过于细粒度，则其中的几个服务可能需要交互来满足用户请求。在最坏的情况下，数据变更可能会跨多个微服务，可能会产生分布式事务的场景。

**粒度-适中的微服务**

微服务设计成熟度的一个重要方面是创建粒度适中的微服务的能力。这里的解决方案不是任何工具或技术中，而是在适当的领域建模上。为后端服务建模并为其定义微服务边界可以通过多种方式完成。业界流行的一种驱动微服务范围的方法是遵循领域驱动设计（Domain-Driven Design，DDD）原则。简而言之：

一个服务（例如：REST服务）可以具体DDD聚合的作用域。一个微服务的作用域可以是DDD限定的上下文。该微服务中的服务将对应于该限定上下文的聚合。

对于微服务间的通信，我们可以使用：当异步消息满足需求时使用领域事件（Domain Event）；当请求-响应更适合时，使用某种形式的中间层进行API调用；当一个微服务需要另一个可用区的大量数据时，可以使用数据复制保证最终一致性。

## 八、结论

IDEALS是在大多数典型的微服务设计中要遵循的核心设计原则。然而，遵循IDEALS并不是使我们的微服务设计成功的良药。通常，我们还需要对质量需求有一个很好的理解，并使设计决策意识到他们的权衡。此外，我们还应该学习可以用来帮助实现设计原则的设计模式和架构策略。还应该掌握可用的技术选型。

多年来，我一直使用IDEALS设计、实现和部署微服务，在设计研讨会和讲座中，我与来自不同组织的数百名软件开发人员讨论这些核心原则以及每一个原则背后的许多策略。有时候，会让人觉得微服务的工具、框架、平台和模式层出不穷，我相信，对微服务IDEALS更好的理解，能够帮助我们更清晰的了解技术领域。



### Key Takeaways

- For object-oriented design we follow the SOLID principles. For microservice design we propose developers follow the “IDEALS”: interface segregation, deployability (is on you), event-driven, availability over consistency, loose-coupling, and single responsibility.
- Interface segregation tells us that different types of clients (e.g., mobile apps, web apps, CLI programs) should be able to interact with services through the contract that best suits their needs. 
- Deployability (is on you) acknowledges that in the microservice era, which is also the DevOps era, there are critical design decisions and technology choices developers need to make regarding packaging, deploying and running microservices. 
- Event-driven suggests that whenever possible we should model our services to be activated by an asynchronous message or event instead of a synchronous call. Availability over consistency reminds us that more often end users value the availability of the system over strong data consistency, and they’re okay with eventual consistency. 
- Loose-coupling remains an important design concern in the case of microservices, with respect to afferent (incoming) and efferent (outgoing) coupling. Single responsibility is the idea that enables modeling microservices that are not too large or too slim because they contain the right amount of cohesive functionality.
  

In 2000 Robert C. Martin compiled the five principles of object-oriented design listed below. Michael Feathers later combined these principles in the SOLID acronym. Since then, the SOLID principles for OO design have been described in books and became well-known in the industry.

- Single responsibility principle
- Open/closed principle
- Liskov substitution principle
- Interface segregation principle
- Dependency inversion principle

A couple of years ago, I was teaching microservice design to fellow developers when one of the students asked, "Do the SOLID principles apply to microservices?" After some thought, my answer was, "In part."

Months later, I found myself searching for the fundamental design principles for microservices (and a catchy acronym to go with it). But why would such a question be important?

[**Start Free Trial**](https://www.infoq.com/infoq/url.action?i=00d241fb-f31a-4d67-9e3d-353aa5751c7e&t=f).

We, as an industry, have been designing and implementing microservice-based solutions for over six years now. During this time, an ever-increasing number of tools, frameworks, platforms, and supporting products have established an incredibly rich technology landscape around microservices.

This landscape can make a novice microservice developer dizzy with the many design decisions and technology choices they can face in just one microservice project.

In this space, a core set of principles can help developers to aim their design decisions in the right direction for microservice-based solutions.

Although some of the SOLID principles apply to microservices, object orientation is a design paradigm that deals with elements (classes, interfaces, hierarchies, etc.) that are fundamentally different from elements in distributed systems in general, and microservices in particular.

Thus, we propose the following set of core principles for microservice design:

- **I**nterface segregation
- **D**eployability (is on you)
- **E**vent-driven
- **A**vailability over consistency
- **L**oose coupling
- **S**ingle responsibility

The principles don’t cover the whole spectrum of design decisions for microservices-based solutions, but they touch the key concerns and success factors for creating modern service-based systems. Read on for an explanation of these principles applied to microservices -- the much-needed microservice "IDEALS."

## Interface Segregation

The original [Interface Segregation Principle](https://web.archive.org/web/20150905081110/http:/www.objectmentor.com/resources/articles/isp.pdf) admonishes OO classes with "fat" interfaces. In other words, instead of a class interface with all possible methods clients might need, there should be separate interfaces catering to the specific needs of each type of client.

The microservice architecture style is a specialization of the service-oriented architecture, wherein the design of interfaces (i.e., service contracts) has always been of utmost importance. Starting in the early 2000s, SOA literature would prescribe canonical models or canonical schemas, with which all service clients should comply. However, the way we approach service contract design has changed since the old days of SOA. In the era of microservices, there is often a multitude of client programs (frontends) to the same service logic. That is the main motivation to apply interface segregation to microservices.

### Realizing interface segregation for microservices

The goal of interface segregation for microservices is that each type of frontend sees the service contract that best suits its needs. For example: a mobile native app wants to call endpoints that respond with a short JSON representation of the data; the same system has a web application that uses the full JSON representation; there’s also an old desktop application that calls the same service and requires a full representation but in XML. Different clients may also use different protocols. For example, external clients want to use HTTP to call a gRPC service.

Instead of trying to impose the same service contract (using canonical models) on all types of service clients, we "segregate the interface" so that each type of client sees the service interface that it needs. How do we do that? A prominent alternative is to use an API gateway. It can do message format transformation, message structure transformation, protocol bridging, message routing, and much more. A popular alternative is the [Backend for Frontends](https://samnewman.io/patterns/architectural/bff/) (BFF) pattern. In this case, we have an API gateway for each type of client -- we commonly say we have a different BFF for each client, as illustrated in this figure.

![img](https://res.infoq.com/articles/microservices-design-ideals/en/resources/1figure-1-different-BFF-for-each-client-1598955550326.jpg)

## Deployability (is on you)

For virtually the entire history of software, the design effort has focused on design decisions related to how implementation units (modules) are organized and how runtime elements (components) interact. Architecture tactics, design patterns, and other design strategies have provided guidelines for organizing software elements in layers, avoiding excessive dependencies, assigning specific roles or concerns to certain types of components, and other design decisions in the "software" space. For microservice developers, there are critical design decisions that go beyond the software elements.

As developers, we have long been aware of the importance of properly packaging and deploying software to an appropriate runtime topology. However, we have never paid so much attention to the deployment and runtime monitoring as today with microservices. The realm of technology and design decisions that here we’re calling "deployability" has become critical to the success of microservices. The main reason is the simple fact that microservices dramatically increase the number of deployment units.

So, the letter D in IDEALS indicates to the microservice developer that they are also responsible for making sure the software and its new versions are readily available to its happy users. Altogether, deployability involves:

- Configuring the runtime infrastructure, which includes containers, pods, clusters, persistence, security, and networking.
- Scaling microservices in and out, or migrating them from one runtime environment to another.
- Expediting the commit+build+test+deploy process.
- Minimizing downtime for replacing the current version.
- Synchronizing version changes of related software.
- Monitoring the health of the microservices to quickly identify and remedy faults.

### Achieving good deployability

Automation is the key to effective deployability. Automation involves wisely employing tools and technologies, and this is the space where we have continuously seen the most change since the advent of microservices. Therefore, microservice developers should be on the lookout for new directions in terms of tools and platforms, but always questioning the benefits and challenges of each new choice. (Important sources of information have been the ThoughtWorks [Technology Radar](https://www.thoughtworks.com/radar)and the [Software Architecture and Design InfoQ Trends Report](https://www.infoq.com/articles/architecture-trends-2020/).)

Here is a list of strategies and technologies that developers should consider in any microservice-based solution to improve deployability:

- **Containerization and container orchestration**: a containerized microservice is much easier to replicate and deploy across platforms and cloud providers, and an orchestration platform provides shared resources and mechanisms for routing, scaling, replication, load-balancing, and more. Docker and Kubernetes are today’s de facto standards for containerization and container orchestration.
- **Service mesh**: this kind of tool can be used for traffic monitoring, policy enforcement, authentication, RBAC, routing, circuit breaker, message transformation, among other things to help with the communication in a container orchestration platform. Popular service meshes include Istio, Linkerd, and Consul Connect.
- **API gateway**: by intercepting calls to microservices, an API gateway product provides a rich set of features, including message transformation and protocol bridging, traffic monitoring, security controls, routing, cache, request throttling and API quota, and circuit breaking. Prominent players in this space include Ambassador, Kong, Apiman, WSO2 API Manager, Apigee, and Amazon API Gateway.
- **Serverless architecture**: you can avoid much of the complexity and operational cost of container orchestration by deploying your services to a serverless platform, which follows the FaaS paradigm. AWS Lambda, Azure Functions, and Google Cloud Functions are examples of serverless platforms.
- **Monitoring tools**: with microservices spread across your on-premises and cloud infrastructure, being able to predict, detect, and notify issues related to the health of the system is critical. There are several monitoring tools available, such as New Relic, CloudWatch, Datadog, Prometheus, and Grafana.
- **Log consolidation tools**: microservices can easily increase the number of deployment units by an order of magnitude. We need tools to consolidate the log output from these components, with the ability to search, analyze, and generate alerts. Popular tools in this space are Fluentd, Graylog, Splunk, and ELK (Elasticsearch, Logstash, Kibana).
- **Tracing tools**: these tools can be used to instrument your microservices, and then produce, collect, and visualize runtime tracing data that shows the calls across services. They help you to spot performance issues (and sometimes even help you to understand the architecture). Examples of tracing tools are Zipkin, Jaeger, and AWS X-Ray.
- **DevOps**: microservices work better when devs and ops teams communicate and collaborate more closely, from infrastructure configuration to incident handling.
- **Blue-green deployment and canary releasing**: these deployment strategies allow zero or near-zero downtime when releasing a new version of a microservice, with a quick switchback in case of problems.
- **Infrastructure as Code (IaC)**: this practice enables minimal human interaction in the build-deploy cycle, which becomes faster, less error-prone, and more auditable.
- **Continuous delivery**: this is a required practice to shorten the commit-to-deploy interval yet keeping the quality of the solutions. Traditional CI/CD tools include Jenkins, GitLab CI/CD, Bamboo, GoCD, CircleCI, and Spinnaker. More recently, GitOps tools such as Weaveworks and Flux have been added to the landscape, combining CD and IaC.
- **Externalized configuration**: this mechanism allows configuration properties to be stored outside the microservice deployment unit and easily managed.

## Event-Driven

The microservice architecture style is for creating (backend) services that are typically activated using one of these three general types of connectors:

- HTTP call (to a REST service)
- RPC-like call using a platform-specific component technology, such as gRPC or GraphQL
- An asynchronous message that goes through a queue in a message broker

The first two are typically synchronous, HTTP calls being the most common alternative. Often, services need to call others forming a service composition, and many times the interaction in a service composition is *synchronous*. If instead, we create (or adapt) the participating services to connect and receive messages from a queue/topic, we’ll be creating an event-driven architecture. (One can debate the difference between message-driven and event-driven, but we’ll use the terms interchangeably to represent asynchronous communication over the network using a queue/topic provided by a message broker product, such as Apache Kafka, RabbitMQ, and Amazon SNS.)
An important benefit of an event-driven architecture is improved scalability and throughput. This benefit stems from the fact that message senders are not blocked waiting for a response, and the same message/event can be consumed in parallel by multiple receivers in a publish-subscribe fashion.

### Event-driven microservice

The letter E in IDEALS is to remind us to strive for modeling event-driven microservices because they are more likely to meet the scalability and performance requirements of today’s software solutions. This kind of design also promotes loose-coupling since message senders and receivers -- the microservices -- are independent and don’t know about each other. Reliability is also improved because the design can cope with temporary outages of microservices, which later can catch up with processing the messages that got queued up.

But event-driven microservices, also known as reactive microservices, can present challenges. Processing is activated asynchronously and happens in parallel, possibly requiring synchronization points and correlation identifiers. The design needs to account for faults and lost messages -- correction events, and mechanisms for undoing data changes such as the Saga pattern are often necessary. And for user-facing transactions carried over by an event-driven architecture, the *user experience*should be carefully conceived to keep the end-user informed of progress and mishaps.

## Availability over Consistency

The CAP theorem essentially gives you two options: availability XOR consistency. We see an enormous effort in the industry to provide mechanisms that enable you to choose availability, ergo embrace *eventual consistency*. The reason is simple: today’s end users will not put up with a lack of availability. Imagine a web store during Black Friday. If we enforced *strong consistency* between stock quantity shown when browsing products and the actual stock updated upon purchases, there would be significant overhead for data changes. If any service that updates stock were temporarily unreachable, the catalog could not show stock information and checkout would be out of service! If instead, we choose availability (accepting the risk of occasional inconsistencies), users can make purchases based on stock data that might be slightly out-of-date. One in a few hundred or thousand transactions may end up with an unlucky user later getting an email apologizing for a cancelled purchase due to incorrect stock information at checkout time. Yet, from the user (and the business) perspective, this scenario is better than having the system unavailable or super slow to all users because the system is trying to enforce strong consistency.

Some business operations do require strong consistency. However, as [Pat Helland](https://queue.acm.org/detail.cfm?id=3236388)points out, when faced with the question of whether you want it right or you want it right now, humans usually want an answer right now rather than right.

### Availability with eventual consistency

For microservices, the main strategy that enables the availability choice is data replication. Different design patterns can be employed, sometimes combined:

- **Service Data Replication pattern**: this basic pattern is used when a microservice needs to access data that belongs to other applications (and API calls are not suitable to get the data). We create a replica of that data and make it readily available to the microservice. The solution also requires a data synchronization mechanism (e.g., ETL tool/program, publish-subscribe messaging, materialized views), which will periodically or trigger-based make the replica and master data consistent.
- **[Command Query Responsibility Segregation](https://martinfowler.com/bliki/CQRS.html) (CQRS) pattern**: here we separate the design and implementation of operations that change data (commands) from the ones that only read data (queries). CQRS typically builds on Service Data Replication for the queries for improved performance and autonomy.
- **[Event Sourcing](https://saturn2017.sched.com/event/9kcg/an-in-depth-look-at-event-sourcing-with-command-query-responsibility-segregation) pattern**: instead of storing the current state of an object in the database, we store the sequence of append-only, immutable events that affected that object. Current state is obtained by replaying events, and we do so to provide a "query view" of the data. Thus, Event Sourcing typically builds upon a CQRS design.

A CQRS design we often use at my workplace is shown in the figure next. HTTP requests that can change data are processed by a REST service that operates on a centralized Oracle database (this service uses the Database per Microservice pattern nonetheless). The read-only HTTP requests go to a different backend service, which reads the data from an Elasticsearch text-based data store. A Spring Batch Kubernetes cron job is executed periodically to update the Elasticsearch store based on data changes executed on the Oracle DB. This setup uses eventual consistency between the two data stores. The query service is available even if the Oracle DB or the cron job is inoperative.

![img](https://res.infoq.com/articles/microservices-design-ideals/en/resources/1figure-2-update-Elasticsearch-store-based-on-data-changes-executed-on-the-Oracle-DB-1598955550687.jpg)

## Loose-Coupling

In software engineering, coupling refers to the degree of interdependence between two software elements. For service-based systems, *afferent coupling* is related to how service users interact with the service. We know this interaction should be through the service contract. Also, the contract should not be tightly coupled to implementation details or a specific technology. A service is a distributed component that can be called by different programs. Sometimes, the service custodian doesn’t even know where all the service users are (often the case for public API services). Therefore, contract changes should be avoided in general. If the service contract is tightly coupled to the service logic or technology, then it is more prone to change when the logic or technology needs to evolve.

Services often need to interact with other services or other types of components thus generating *efferent coupling*. This interaction establishes runtime dependencies that directly impact the service autonomy. If a service is less autonomous, its behavior is less predictable: in the best-case scenario, the service will be as fast, reliable, and available as the slowest, least reliable, and least available component it needs to call.

### Loose coupling strategies for services

The letter L in IDEALS prompts us to be attentive to coupling for services and therefore microservices. Several strategies can be used and combined to promote (afferent and efferent) loose coupling. Examples of such strategies include:

- **Point-to-point and publish-subscribe**: these building block messaging patterns and their variations promote loose coupling because senders and receivers are not aware of each other; the contract of a reactive microservice (e.g., a Kafka consumer) becomes the name of the message queue and the structure of the message.
- **API gateway and BFF**: these solutions prescribe an intermediary component that deals with any discrepancies between the contract of the service and the message format and protocol that the client wants to see, hence helping to uncouple them.
- **Contract-first design**: by designing the contract independently of any existing code we avoid creating APIs that are tightly coupled to technology and implementation.
- **Hypermedia**: for REST services, hypermedia helps frontends to be more independent of service endpoints.
- **Façade and Adapter/Wrapper patterns**: variations of these GoF patterns in microservice architectures can prescribe internal components or even services that can prevent undesirable coupling to spread across a microservice implementation.
- **Database per Microservice pattern**: with this pattern, microservices not only gain in autonomy but also avoid direct coupling to shared databases.

## Single Responsibility

The original Single Responsibility Principle (SRP) is about having cohesive functionality in an OO class. Having multiple responsibilities in a class naturally leads to tight coupling, and results in fragile designs that are hard to evolve and can break in unexpected ways upon changing. The idea is simple, but as Uncle Bob pointed out, SRP is very easy to understand, but difficult to get right.

The notion of single responsibility can be extended to the cohesiveness of services within a microservice. The microservice architecture style dictates that the [deployment unit should contain only one service or just a few cohesive services](https://insights.sei.cmu.edu/saturn/2015/11/defining-microservices.html). If a microservice is packed with responsibilities, that is, too many not quite cohesive services, then it might bear the pains of a monolith. A bloated microservice becomes harder to evolve in terms of functionality and the technology stack. Also, continuous delivery becomes burdensome with many developers working on several moving parts that go in the same deployment unit.

On the other hand, if microservices are too fine-grained, more likely several of them will need to interact to fulfill a user request. In the worst-case scenario, data changes might be spread across different microservices, possibly creating a distributed transaction scenario.

### Right-grained microservices

An important aspect of maturity in microservice design is the ability to create microservices that are not too coarse- or too fine-grained. Here the solution is not in any tool or technology, but rather on proper *domain modeling*. Modeling the backend services and defining microservice boundaries for them can be done in many ways. An approach that has become popular in the industry to drive the scope of microservices is to follow [Domain-Driven Design (DDD)](https://www.infoq.com/minibooks/domain-driven-design-quickly/) precepts. In brief:

- A service (e.g., a REST service) can have the scope of a DDD aggregate.
- A microservice can have the scope of a DDD bounded context. Services within that microservice will correspond to the aggregates within that bounded context.
- For inter-microservice communication, we can use: domain events when asynchronous messaging fits the requirements; API calls using some form of an anti-corruption layer when a request-response connector is more appropriate; or data replication with eventual consistency when a microservice needs a substantial amount of data from the other BC readily available.

## Conclusion

IDEALS are the core design principles to be followed in most typical microservice designs. However, following the IDEALS is not a magic potion or spell that will make our microservice design successful. As always, we need to have a good understanding of the quality attribute requirements and make design decisions aware of their tradeoffs. Moreover, we should learn about the design patterns and architecture tactics that can be employed to help realize the design principles. We should also have a good grasp of the technology choices available.

I have employed IDEALS in designing, implementing, and deploying microservices for several years now. In design workshops and talks, I have discussed these core principles and the many strategies behind each with a few hundred software developers from different organizations. I know at times it feels like there is a landslide of tools, frameworks, platforms, and patterns for microservices. I believe a good understanding of microservice IDEALS will help you navigate the technology space with more clarity.

*Many thanks to Joe Yoder for helping to evolve these ideas into IDEALS.*