const { parse } = require("json2csv");
const fs = require("fs");
const axios = require("axios");
const FormData = require("form-data");

const exportTransactions = async (source, account_id, dates, iban = null) => {
  setImmediate(async () => {
    const webhookUrl = global.exports[GetCurrentResourceName()].exportWebhook();

    if (!webhookUrl) {
      console.error(
        `You need to set an export webhook in the config for the transactions to be exported`
      );

      TriggerClientEvent(
        "fd_banking:client:transactions:exported",
        source,
        false,
        null
      );

      return;
    }

    if (iban) {
      const account = await exports.oxmysql.single_async(
        `SELECT id FROM fd_advanced_banking_accounts WHERE iban = ?`
      );

      if (!account) {
        TriggerClientEvent(
          "fd_banking:client:transactions:exported",
          source,
          false,
          null
        );
      }

      account_id = account.id;
    }

    const transactions = await exports.oxmysql.query_async(
      `
        SELECT
            transactions.action,
            transactions.done_by as doneBy,
            transactions.from_account as fromAccount,
            transactions.to_account as toAccount,
            transactions.amount,
            transactions.description,
            DATE_FORMAT(CONVERT_TZ(transactions.created_at, @@session.time_zone, '+00:00')  ,'%Y-%m-%dT%TZ') as doneAt,
            accounts.iban
        FROM
            fd_advanced_banking_accounts_transactions transactions
        INNER JOIN
            fd_advanced_banking_accounts accounts on transactions.account_id = accounts.id
        WHERE
            transactions.account_id = ? AND
            transactions.created_at BETWEEN ? AND ?
        `,
      [account_id, dates.startDate, dates.endDate]
    );

    try {
      const fields = [
        "iban",
        "action",
        "doneBy",
        "fromAccount",
        "toAccount",
        "amount",
        "description",
        "doneAt",
      ];

      const opts = { fields };

      const csv = parse(transactions, opts);

      const fileName = `transactions-${account_id}-${new Date().valueOf()}.csv`;
      const filePath = `${GetResourcePath(
        GetCurrentResourceName()
      )}/${fileName}`;

      fs.writeFileSync(filePath, csv);

      const formData = new FormData();

      formData.append("files[0]", fs.createReadStream(filePath));

      const response = await axios({
        method: "post",
        url: webhookUrl,
        data: formData,
        headers: {
          "Content-Type": "multipart/form-data",
        },
      });

      const {
        data: {
          attachments: [transaction],
        },
      } = response;

      await fs.unlinkSync(filePath);

      TriggerClientEvent(
        "fd_banking:client:transactions:exported",
        source,
        true,
        transaction.url
      );
    } catch (err) {
      console.error(err);
      TriggerClientEvent(
        "fd_banking:client:transactions:exported",
        source,
        false,
        null
      );
    }
  });
};

global.exports("exportTransactions", exportTransactions);
