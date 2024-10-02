
using Microsoft.ApplicationInsights.Channel;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.Extensions.Azure;

namespace WebApi2
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.

            builder.Services.AddControllers();
            // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();

            builder.Services.AddApplicationInsightsTelemetry();
            builder.Services.AddSingleton<ITelemetryInitializer, MyTelemetryInitializer>();
            builder.Services.AddServiceProfiler();
            builder.Services.AddSnapshotCollector();

            builder.Services.AddHttpClient();
            builder.Services.AddAzureClients(acfbuilder =>
            {
                var strconstr = builder.Configuration["STORAGE_CONNECTION_STRING"]!.ToString();
                acfbuilder.AddBlobServiceClient(strconstr);
                acfbuilder.AddQueueServiceClient(strconstr);

            });


            var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {
                app.UseSwagger();
                app.UseSwaggerUI();
            }

            app.UseAuthorization();


            app.MapControllers();

            app.Run();
        }
    }

    public class MyTelemetryInitializer : ITelemetryInitializer
    {
        public void Initialize(ITelemetry telemetry)
        {
            telemetry.Context.Cloud.RoleName = typeof(Program).Namespace;
        }
    }

}
