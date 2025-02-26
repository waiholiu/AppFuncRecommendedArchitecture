using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using Microsoft.Data.SqlClient;
using Azure.Identity;
using System.Text.Json;
using System.Collections.Generic;

namespace Company.Function
{
    public class HttpTrigger1
    {
        private readonly ILogger<HttpTrigger1> _logger;
        private readonly string _connectionString = "Server=tcp:wl-xxx-db-server.database.windows.net,1433;Initial Catalog=db;";

        public HttpTrigger1(ILogger<HttpTrigger1> logger)
        {
            _logger = logger;
        }

        [Function("HttpTrigger1")]
        public IActionResult Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequest req)
        {
            _logger.LogInformation("C# HTTP trigger function processed a request.");

            var result = new List<Dictionary<string, object>>();

            var credential = new DefaultAzureCredential();
            var token = credential.GetToken(new Azure.Core.TokenRequestContext(new[] { "https://database.windows.net/.default" }));

            using (SqlConnection conn = new SqlConnection(_connectionString))
            {
                conn.AccessToken = token.Token;
                conn.Open();
                var text = "SELECT *   FROM [dbo].[Employees]";

                using (SqlCommand cmd = new SqlCommand(text, conn))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var row = new Dictionary<string, object>();
                            for (int i = 0; i < reader.FieldCount; i++)
                            {
                                row[reader.GetName(i)] = reader.GetValue(i);
                            }
                            result.Add(row);
                        }
                    }
                }
            }

            return new OkObjectResult(JsonSerializer.Serialize(result));
        }
    }
}