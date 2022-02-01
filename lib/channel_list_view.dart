import 'package:channel_unread_count_issue/main.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'dart:math';
import 'models/sign_up_with_phone_number_response.dart';

class ChannelView extends StatefulWidget {
  const ChannelView({Key? key, required this.res}) : super(key: key);
  final SignUpWithPhoneNumberResponse res;

  @override
  _ChannelViewState createState() => _ChannelViewState();
}

class _ChannelViewState extends State<ChannelView> {

  bool isUserUpdating = false;
  @override
  Widget build(BuildContext context) {
    return StreamChat(
      client: client,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            MaterialButton(
              onPressed: () async {
                setState(() {
                  isUserUpdating =  true;
                });
                final user = User(
                    id: widget.res.data.userUid!,
                    extraData: {'name': "${generateRandomString(5)}"});
                await client.updateUser(user);
                setState(() {
                  isUserUpdating =  false;
                });
              },
              child: const Text("Update user"),
            ),
            const SizedBox(
              width: 20,
            ),
            MaterialButton(
              onPressed: () async {
                await client.disconnectUser();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const MyHomePage(
                              title: 'Total channel unread count demo',
                            )),
                    (route) => false);
              },
              child: const Text("Logout"),
            )
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.05,
                  ),
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: Column(
                    children: [
                      Text(
                        "Total channel unread count",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      StreamBuilder(
                          stream: StreamChat.of(context)
                              .client
                              .state
                              .unreadChannelsStream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(snapshot.data.toString(),
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold));
                            }
                            return const Text("0",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold));
                          })
                    ],
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: ChannelsBloc(
                    child: ChannelListView(
                      limit: 20,
                      filter: Filter.in_('members', [widget.res.data.userUid!]),
                      sort: [SortOption('last_message_at')],
                      channelWidget: ChannelPage(),
                    ),
                  ),
                ),
              ],
            ),
             Visibility(
                visible: isUserUpdating,
                child: Center(child: const CircularProgressIndicator())),
          ],
        ),
      ),
    );
  }

  // Generate random string
  String generateRandomString(int length) {
    final _random = Random();
    const _availableChars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
    final randomString = List.generate(length,
            (index) => _availableChars[_random.nextInt(_availableChars.length)])
        .join();

    return randomString;
  }
}

class ChannelPage extends StatelessWidget {
  const ChannelPage({
    Key? key,
  }) : super(key: key);

  @override
  // ignore: prefer_expression_function_bodies
  Widget build(BuildContext context) {
    return StreamChannel(
      channel: StreamChannel.of(context).channel,
      child: Scaffold(
        appBar: const ChannelHeader(),
        body: Column(
          children: const <Widget>[
            Expanded(
              child: MessageListView(),
            ),
            MessageInput(),
          ],
        ),
      ),
    );
  }
}
