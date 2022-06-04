defmodule Zout.AccountsTest do
  use Zout.DataCase, async: true

  alias Zout.Accounts
  alias Zout.Accounts.User

  describe "get_user/1" do
    test "gets existing users" do
      expected_user = insert(:user)
      actual_user = Accounts.get_user(expected_user.id)

      assert actual_user == expected_user
    end

    test "does not get non-existing user" do
      actual_user = Accounts.get_user(-1)

      assert is_nil(actual_user)
    end
  end

  describe "update_or_create/1" do
    test "saves new user" do
      new_user = %Ueberauth.Auth{
        uid: 693,
        info: %Ueberauth.Auth.Info{
          nickname: "new-user"
        },
        extra: %Ueberauth.Auth.Extra{raw_info: %{admin: true}}
      }

      user_count_before = Repo.aggregate(User, :count, :id)
      inserted_user = Accounts.update_or_create!(new_user)
      user_count_after = Repo.aggregate(User, :count, :id)

      assert inserted_user.id == new_user.uid
      assert inserted_user.nickname == new_user.info.nickname
      assert inserted_user.admin == new_user.extra.raw_info.admin
      assert_in_delta user_count_after, user_count_before, 1
    end

    test "updates existing user" do
      existing_user = insert(:user, nickname: "before", admin: false)

      auth_user = %Ueberauth.Auth{
        uid: existing_user.id,
        info: %Ueberauth.Auth.Info{
          nickname: "after"
        },
        extra: %Ueberauth.Auth.Extra{raw_info: %{admin: true}}
      }

      user_count_before = Repo.aggregate(User, :count, :id)
      updated_user = Accounts.update_or_create!(auth_user)
      user_count_after = Repo.aggregate(User, :count, :id)

      assert updated_user.id == existing_user.id
      assert updated_user.nickname == "after"
      assert updated_user.admin == true
      assert user_count_after == user_count_before
    end
  end
end
