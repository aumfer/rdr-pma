import Redis from 'ioredis';
import _ from 'lodash';
import http from 'http';
import SocketIO from 'socket.io';
import {Observable} from 'rxjs';
import {publish, refCount, distinct} from 'rxjs/operators';

const redisUrl = process.env.REDIS_URL || 'redis://127.0.0.1:6379';
const redis = new Redis(redisUrl);

// todo store this value somewhere, so we don't lose transactions while the server is down
//let lastId = '-';
let lastId = Date.now().toString();

const transactions = new Observable(observer => {
    const poll = function poll() {
        redis.xrange('rdr', lastId, '+').then(function onPublishedTransaction(result) {
            // ignore empty responses
            if (!result || !result.length) return;

            _.each(result, val => {
                // xrange start is inclusive, ignore lastId
                if (val[0] == lastId) return;

                lastId = val[0];
                const data = _.fromPairs(_.chunk(val[1], 2));
                console.log(`onPublishedTransaction: ${JSON.stringify(data)}`);
                observer.next(data);
            });
        }).finally(function onPollComplete() {
            poll();
        });
    };
    poll();
})
// only get each transaction once
.pipe(distinct((tx:any) => tx.hash))
// multi-cast to clients
.pipe(publish()).pipe(refCount());

// debug subscribe to transactions even if noone is connected
transactions.subscribe();

const httpServer = http.createServer(function onRequest(request, response) {
    response.write('hello, world!');
});
httpServer.listen(80);

const socketIo = SocketIO(httpServer);
socketIo.on('connection', function onConnection(socket) {
    transactions.subscribe(function onTransactionToSend(transaction) {
        console.log(`onTransactionToSend: ${JSON.stringify(transaction)}`);
        socket.send(transaction);
    });
});
