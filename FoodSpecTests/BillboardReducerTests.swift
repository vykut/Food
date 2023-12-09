//
//  BillboardReducerTests.swift
//  FoodSpecTests
//
//  Created by Victor Socaciu on 09/12/2023.
//

import XCTest
import ComposableArchitecture
@testable import Billboard
@testable import FoodSpec

@MainActor
final class BillboardReducerTests: XCTestCase {
    func testOnAppear() async throws {
        let store = TestStore(
            initialState: FoodListReducer.State(),
            reducer: {
                BillboardReducer()
            }
        )
        store.dependencies.billboardClient.getRandomBanners = {
            .init {
                $0.yield(.preview)
                $0.yield(nil)
                $0.yield(.preview)
                $0.finish()
            }
        }
        await store.send(.onAppear)
        await store.receive(\.billboard.showBanner) {
            $0.billboard.banner = .preview
        }
        await store.receive(\.billboard.showBanner) {
            $0.billboard.banner = nil
        }
        await store.receive(\.billboard.showBanner) {
            $0.billboard.banner = .preview
        }
    }

    func testOnAppear_billboardClientError() async throws {
        let store = TestStore(
            initialState: FoodListReducer.State(),
            reducer: {
                BillboardReducer()
            }
        )
        store.dependencies.billboardClient.getRandomBanners = {
            .init {
                struct Failure: Error { }
                $0.finish(throwing: Failure())
            }
        }
        await store.send(.onAppear)
    }

    func testShowBanner() async throws {
        let store = TestStore(
            initialState: FoodListReducer.State(),
            reducer: {
                BillboardReducer()
            }
        )
        await store.send(.billboard(.showBanner(.preview))) {
            $0.billboard.banner = .preview
        }
    }
}

extension BillboardAd {
    static var preview: Self {
        .init(
            appStoreID: "appStoreID",
            name: "name",
            title: "title",
            description: "description",
            media: .temporaryDirectory,
            backgroundColor: "backgroundColor",
            textColor: "textColor",
            tintColor: "tintColor",
            fullscreen: false,
            transparent: false
        )
    }
}