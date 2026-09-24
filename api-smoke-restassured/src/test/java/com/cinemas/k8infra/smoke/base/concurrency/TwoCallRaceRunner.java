package com.cinemas.k8infra.smoke.base.concurrency;

import java.util.concurrent.Callable;
import java.util.concurrent.CyclicBarrier;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.TimeoutException;

public final class TwoCallRaceRunner {
    private TwoCallRaceRunner() {
    }

    /** Runs two callables with synchronized start and returns both results. */
    public static <T> Pair<T> run(Callable<T> callA, Callable<T> callB, int timeoutSeconds) throws Exception {
        try (ExecutorService pool = Executors.newFixedThreadPool(2)) {
            CyclicBarrier startBarrier = new CyclicBarrier(2);
            Future<T> futureA = pool.submit(wrapWithBarrier(startBarrier, callA));
            Future<T> futureB = pool.submit(wrapWithBarrier(startBarrier, callB));
            try {
                return new Pair<>(futureA.get(timeoutSeconds, TimeUnit.SECONDS), futureB.get(timeoutSeconds, TimeUnit.SECONDS));
            } catch (TimeoutException timeout) {
                futureA.cancel(true);
                futureB.cancel(true);
                throw timeout;
            }
        }
    }

    /** Wraps a callable so both participants start only after the barrier opens. */
    private static <T> Callable<T> wrapWithBarrier(CyclicBarrier startBarrier, Callable<T> call) {
        return () -> {
            startBarrier.await(10, TimeUnit.SECONDS);
            return call.call();
        };
    }

    public record Pair<T>(T first, T second) {
    }
}

