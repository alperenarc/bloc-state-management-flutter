import 'package:bloc_state_management/bloc/cats_repository.dart';
import 'package:bloc_state_management/bloc/cats_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import 'cats_cubit.dart';

class BlocCatsView extends StatefulWidget {
  @override
  _BlocCatsViewState createState() => _BlocCatsViewState();
}

class _BlocCatsViewState extends State<BlocCatsView> {
  // @override
  // void initState() {
  //   super.initState();
  //   context.bloc<CatsCubit>().getCats();
  // }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) {
          final catCubit = CatsCubit(SampleCatsRepository());
          catCubit.getCats();
          return catCubit;
        },
        child: buildScaffold(context));
  }

  Scaffold buildScaffold(BuildContext ctx) => Scaffold(
        appBar: AppBar(
          title: Text('Hello'),
        ),
        body: BlocConsumer<CatsCubit, CatsState>(
          listener: (context, state) {
            if (state is CatsError) {
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is CatsInitial) {
              return Center(
                child: Column(
                  children: [
                    buildFloatingActionButton(context),
                    Text('Initial'),
                  ],
                ),
              );
            } else if (state is CatsLoading) {
              return LoadingListTileWidget();
            } else if (state is CatsCompleted) {
              return ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: state.response.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(index.toString()),
                    onDismissed: (direction) {
                      // setState(() {
                      //   state.response.insert(index, new Cat())
                      // });
                      Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text("$index dismissed")));
                    },
                    // Show a red background as the item is swiped away.
                    // background: Container(color: Colors.red),
                    direction: DismissDirection.startToEnd,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.delete_forever,
                        color: Colors.white,
                      ),
                    ),
                    child: listItem(state, index),
                  );
                },
              );
            } else {
              final error = state as CatsError;
              return Text(error.message);
            }
          },
        ),
      );

  ListTile listItem(CatsCompleted state, int index) {
    return ListTile(
      title: Text(state.response[index].statusCode.toString()),
      subtitle: Text(state.response[index].description),
      leading: CachedNetworkImage(
        imageUrl: state.response[index].imageUrl,
        imageBuilder: (context, imageProvider) => Container(
          width: 80.0,
          height: 80.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
    );
  }

  FloatingActionButton buildFloatingActionButton(BuildContext ctx) {
    return FloatingActionButton(
      child: Icon(Icons.get_app),
      onPressed: () {
        ctx.bloc<CatsCubit>().getCats();
      },
    );
  }
}

class LoadingListTileWidget extends StatelessWidget {
  const LoadingListTileWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300],
      highlightColor: Colors.grey[100],
      child: ListView.builder(
        physics: BouncingScrollPhysics(),
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            title: Container(
              color: Colors.grey,
              width: MediaQuery.of(context).size.width * 0.2,
              height: 10,
            ),
            subtitle: Container(
              color: Colors.grey,
              width: MediaQuery.of(context).size.width * 0.1,
              height: 10,
            ),
            leading: Container(
              width: 80,
              height: 80,
              child: CircleAvatar(
                foregroundColor: Colors.grey,
                // radius: 80,
              ),
            ),
          );
        },
      ),
    );
  }
}
